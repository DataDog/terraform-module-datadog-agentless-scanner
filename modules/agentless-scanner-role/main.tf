locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "role" {
  name        = var.iam_role_name
  path        = var.iam_role_path
  description = "Role used by the Datadog agentless scanner instance"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = merge(var.tags, local.dd_tags)
}

resource "aws_iam_instance_profile" "profile" {
  role = aws_iam_role.role.name

  name = var.iam_role_name
  path = var.iam_role_path

  tags = merge(var.tags, local.dd_tags)
}

data "aws_iam_policy_document" "scanner_policy_document" {
  statement {
    sid       = "AssumeCrossAccountScanningRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = var.account_roles
  }

  dynamic "statement" {
    for_each = var.api_key_secret_arn != null ? [1] : []

    content {
      sid       = "ReadSecret"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = [var.api_key_secret_arn]
    }
  }

  dynamic "statement" {
    for_each = var.kms_key_arn != null ? [1] : []

    content {
      sid       = "DecryptSecret"
      actions   = ["kms:Decrypt"]
      resources = [var.kms_key_arn]
    }
  }
}

resource "aws_iam_policy" "scanner_policy" {
  name   = var.iam_policy_name
  path   = var.iam_policy_path
  policy = data.aws_iam_policy_document.scanner_policy_document.json
}

resource "aws_iam_role_policy_attachment" "attachment" {
  policy_arn = aws_iam_policy.scanner_policy.arn
  role       = aws_iam_role.role.name
}

resource "aws_iam_role_policy_attachment" "ssm-attachment" {
  count = var.enable_ssm ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.role.name
}
