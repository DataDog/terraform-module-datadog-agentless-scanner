locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

data "aws_caller_identity" "current" {}

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
  statement {
    sid    = "DatadogAgentlessScannerBucketPolicy"
    effect = "Allow"
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
    principals {
      type = "AWS"
      identifiers = [
        var.rds_service_role_arn,
      ]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerAccessS3Objects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        var.iam_delegate_role_arn,
      ]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerListS3Buckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
    ]
    principals {
      type = "AWS"
      identifiers = [
        var.iam_delegate_role_arn,
      ]
    }
  }

  statement {
    sid    = "DenyAllOtherAccess"
    effect = "Deny"
    actions = [
      "s3:GetObject*",
      "s3:ListBucket",
      "s3:PutObject*",
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values = [
        var.iam_delegate_role_arn,
        var.rds_service_role_arn,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_access_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_access_policy_document.json
}

// KMS Key for RDS S3 Exports
resource "aws_kms_key" "agentless_kms_key" {
  description = "This key is used to encrypt bucket objects"
  tags        = merge(var.tags, local.dd_tags)
  policy      = data.aws_iam_policy_document.kms_key_policy_document.json
}

data "aws_iam_policy_document" "kms_key_policy_document" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "DatadogAgentlessKMSKeyPolicy"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.iam_delegate_role_arn]
    }
    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey",
    ]
    resources = ["*"]
  }
}
