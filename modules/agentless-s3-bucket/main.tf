locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

data "aws_region" "current" {}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "datadog-agentless-scanning-"
  tags          = merge(var.tags, local.dd_tags)
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# We use a lifecycle rule to cleanup the bucket instead of having the scanner do it.
# This minimizes the permissions of the scanner needs and ensures the data is always
# cleaned up even if there is an error during the scan.
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    status = "Enabled"
    id     = "expire_all_files"
    expiration {
      days = 2
    }
  }
}

data "aws_iam_policy_document" "bucket_access_policy_document" {
  # TODO: add statement to deny access to everyone except the scanner roles
  statement {
    sid = "DatadogAgentlessScannerBucketPolicy"

    principals {
      type = "AWS"
      identifiers = [
        var.rds_service_role_arn,
      ]
    }

    actions = [
      "s3:PutObject*",
      "s3:ListBucket",
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }

  statement {
    sid = "DatadogAgentlessScannerAccessS3Objects"

    principals {
      type = "AWS"
      identifiers = [
        var.iam_delegate_role_arn,
      ]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }

  statement {
    sid = "DatadogAgentlessScannerListS3Buckets"

    principals {
      type = "AWS"
      identifiers = [
        var.iam_delegate_role_arn,
      ]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
    ]
  }
}

resource "aws_s3_bucket_policy" "bucket_access_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_access_policy_document.json
}

resource "aws_kms_replica_key" "replica" {
  count           = var.primary_kms_key_region == data.aws_region.current.name ? 0 : 1
  description     = "Multi-Region replica key"
  primary_key_arn = var.primary_kms_key_arn
  tags            = merge(var.tags, local.dd_tags)
}
