locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

data "aws_partition" "current" {}

module "scanning_policy" {
  source = "../agentless-scanning-policy"
}


resource "aws_iam_policy" "scanning_orchestrator_policy" {
  name_prefix = "${var.iam_role_name}OrchestratorPolicy"
  path        = var.iam_role_path
  policy      = module.scanning_policy.orchestrator_json
}

resource "aws_iam_policy" "scanning_worker_policy" {
  name_prefix = "${var.iam_role_name}WorkerPolicy"
  path        = var.iam_role_path
  policy      = module.scanning_policy.worker_json
}

resource "aws_iam_policy" "scanning_worker_dspm_policy" {
  count       = var.sensitive_data_scanning_enabled || var.sensitive_data_scanning_rds_enabled ? 1 : 0
  name_prefix = "${var.iam_role_name}WorkerDSPMPolicy"
  path        = var.iam_role_path
  policy      = module.scanning_policy.dspm_json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/DatadogAgentlessScanner"
      values   = ["true"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = var.scanner_roles
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgID"
      values   = var.scanner_organizational_unit_ids
    }
  }
}

resource "aws_iam_role" "role" {
  name        = var.iam_role_name
  path        = var.iam_role_path
  description = "Role assumed by the Datadog Agentless scanner agent to perform scans"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = merge(var.tags, local.dd_tags)
}

resource "aws_iam_role_policy_attachment" "orchestrator_attachment" {
  policy_arn = aws_iam_policy.scanning_orchestrator_policy.arn
  role       = aws_iam_role.role.name
}

resource "aws_iam_role_policy_attachment" "worker_attachment" {
  policy_arn = aws_iam_policy.scanning_worker_policy.arn
  role       = aws_iam_role.role.name
}

resource "aws_iam_role_policy_attachment" "workers_dspm_attachment" {
  count      = length(aws_iam_policy.scanning_worker_dspm_policy)
  policy_arn = aws_iam_policy.scanning_worker_dspm_policy[0].arn
  role       = aws_iam_role.role.name
}

// RDS Specific resources

// RDS Service Role for S3 Exports
data "aws_iam_policy_document" "rds_service_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["export.rds.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "rds_service_role_policy_document" {
  statement {
    actions = [
      "s3:PutObject*",
      "s3:ListBucket",
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::datadog-agentless-scanning-*",
      "arn:aws:s3:::datadog-agentless-scanning-*/*",
    ]
  }
}

resource "aws_iam_role" "rds_service_role" {
  count       = var.sensitive_data_scanning_rds_enabled ? 1 : 0
  name        = "DatadogAgentlessScannerRDSS3ExportRole"
  path        = var.iam_role_path
  description = "Role assumed by the RDS service to write to the S3 bucket"

  assume_role_policy = data.aws_iam_policy_document.rds_service_role_assume_policy.json
  tags               = merge(var.tags, local.dd_tags)
}

resource "aws_iam_policy" "rds_service_role_policy" {
  count       = length(aws_iam_role.rds_service_role)
  name_prefix = "DatadogAgentlessWorkerRDSS3ExportPolicy"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.rds_service_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "rds_service_role_attachment" {
  count      = length(aws_iam_policy.rds_service_role_policy)
  policy_arn = aws_iam_policy.rds_service_role_policy[0].arn
  role       = aws_iam_role.rds_service_role[0].name
}

// RDS Scanning Policy
data "aws_iam_policy_document" "scanning_rds_policy_document" {
  count = length(aws_iam_role.rds_service_role)
  statement {
    sid    = "DatadogAgentlessScannerRDSStartExportTask"
    effect = "Allow"
    actions = [
      "rds:StartExportTask"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:rds:*:*:cluster:*",
      "arn:${data.aws_partition.current.partition}:rds:*:*:cluster-snapshot:*",
      "arn:${data.aws_partition.current.partition}:rds:*:*:snapshot:*",
    ]
    condition {
      test     = "StringNotEquals"
      variable = "aws:ResourceTag/DatadogAgentlessScanner"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerPassRoleToRDS"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.rds_service_role[0].arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "scanning_rds_policy" {
  count       = length(data.aws_iam_policy_document.scanning_rds_policy_document)
  name_prefix = "${var.iam_role_name}WorkerRDSPolicy"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.scanning_rds_policy_document[0].json
}

resource "aws_iam_role_policy_attachment" "delegate_role_rds_policy_attachment" {
  count      = length(aws_iam_policy.scanning_rds_policy)
  policy_arn = aws_iam_policy.scanning_rds_policy[0].arn
  role       = aws_iam_role.role.name
}
