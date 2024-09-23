locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "dd-agentless-"
  tags          = merge(var.tags, local.dd_tags)
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

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
    sid = "DatadogAgentlessScannerBucketPolicy"

    principals {
      type = "AWS"
      identifiers = [
        var.iam_delegate_role_name,
        var.iam_rds_assume_role_name,
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
      "arn:aws:s3:::dd-agentless-*",
      "arn:aws:s3:::dd-agentless-*/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "bucket_access_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_access_policy_document.json
}