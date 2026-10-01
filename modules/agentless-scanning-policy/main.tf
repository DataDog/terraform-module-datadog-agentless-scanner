data "aws_partition" "current" {}

// The IAM policy for the scanning orchestrator allows to create resources
// such as snapshots and volumes. It is also able to cleanup these resources
// after creation. It does not allow reading the created resources.
//
// reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2.html
data "aws_iam_policy_document" "scanning_orchestrator_policy_document" {
  statement {
    sid    = "DatadogAgentlessScannerResourceTagging"
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:*:*:volume/*",
      "arn:${data.aws_partition.current.partition}:ec2:*:*:snapshot/*",
      "arn:${data.aws_partition.current.partition}:ec2:*:*:image/*",
    ]
    // Allow specifying tags when creating snapshots or volumes
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSnapshot", "CreateVolume", "CopySnapshot", "CopyImage"]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerVolumeSnapshotCreation"
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:*:*:volume/*",
    ]
    // Allow creating snapshots from any volume that does not have a
    // DatadogAgentlessScanner:false tag.
    condition {
      test     = "StringNotEquals"
      variable = "aws:ResourceTag/DatadogAgentlessScanner"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerSnapshotCreation"
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:*:*:snapshot/*",
    ]
    // Enforcing created snapshot has DatadogAgentlessScanner tag
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/DatadogAgentlessScanner"
      values   = ["true"]
    }
    // Enforcing created snapshot has only tags with DatadogAgentlessScanner* prefix
    condition {
      test     = "ForAllValues:StringLike"
      variable = "aws:TagKeys"
      values   = ["DatadogAgentlessScanner*"]
    }
  }

  // IAM makes a distinction between source and destination snapshot permissions
  // when using CopySnapshot. We need a policy statement for both of them.
  //
  // reference: https://aws.amazon.com/blogs/storage/enhancing-resource-level-permissions-for-copying-amazon-ebs-snapshots/
  statement {
    sid    = "DatadogAgentlessScannerCopySnapshotSource"
    effect = "Allow"
    actions = [
      "ec2:CopySnapshot"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:*:*:snapshot/snap-*",
    ]
  }

  statement {
    sid    = "DatadogAgentlessScannerCopySnapshotDestination"
    effect = "Allow"
    actions = [
      "ec2:CopySnapshot"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:*:*:snapshot/$${*}",
    ]
    // Enforcing created snapshot has DatadogAgentlessScanner tag
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/DatadogAgentlessScanner"
      values   = ["true"]
    }
    // Enforcing created snapshot has only tags with DatadogAgentlessScanner* prefix
    condition {
      test     = "ForAllValues:StringLike"
      variable = "aws:TagKeys"
      values   = ["DatadogAgentlessScanner*"]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerSnapshotCleanup"
    effect = "Allow"
    actions = [
      // Allow deleting created snapshots and volumes
      "ec2:DeleteSnapshot",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:*:*:snapshot/*",
    ]

    // Enforce that any of these actions can be performed on resources
    // (volumes and snapshots) that have the DatadogAgentlessScanner tag.
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/DatadogAgentlessScanner"
      values   = ["true"]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerImageCleanup"
    effect = "Allow"
    actions = [
      // Allow deleting created images
      "ec2:DeregisterImage",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:*:*:image/*",
    ]

    // Enforce that any of these actions can be performed on images
    // that have the DatadogAgentlessScanner tag.
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/DatadogAgentlessScanner"
      values   = ["true"]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerDescribeSnapshots"
    effect = "Allow"
    actions = [
      // Required to be able to wait for snapshots completion and cleanup. It
      // cannot be restricted.
      "ec2:DescribeSnapshots",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "DatadogAgentlessScannerDescribeVolumes"
    effect = "Allow"
    actions = [
      // Required to be able to wait for volumes completion and cleanup. It
      // cannot be restricted.
      "ec2:DescribeVolumes",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "DatadogAgentlessScannerDescribeImages"
    effect = "Allow"
    actions = [
      // Required to be able to wait for image completion and cleanup. It
      // cannot be restricted.
      "ec2:DescribeImages",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid       = "DatadogAgentlessScannerCopyEncryptedSnapshotGrantKey"
    effect    = "Allow"
    actions   = ["kms:CreateGrant"]
    resources = ["arn:${data.aws_partition.current.partition}:kms:*:*:key/*"]

    // The following conditions enforce that decrypt action
    // can only be performed from calls by ebs API.
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "kms:EncryptionContextKeys"
      values   = ["aws:ebs:id"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["ec2.*.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  statement {
    sid       = "DatadogAgentlessScannerCopyEncryptedSnapshotDescribeKey"
    effect    = "Allow"
    actions   = ["kms:DescribeKey"]
    resources = ["arn:${data.aws_partition.current.partition}:kms:*:*:key/*"]
  }
}

// The IAM policy for the scanning worker allows to read created resources, as
// well as lambdas.
data "aws_iam_policy_document" "scanning_worker_policy_document" {
  statement {
    sid    = "DatadogAgentlessScannerDescribeSnapshots"
    effect = "Allow"
    actions = [
      // Required to be able to wait for snapshots completion and cleanup. It
      // cannot be restricted.
      "ec2:DescribeSnapshots",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "DatadogAgentlessScannerDescribeVolumes"
    effect = "Allow"
    actions = [
      // Required to be able to wait for volumes completion and cleanup. It
      // cannot be restricted.
      "ec2:DescribeVolumes",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "DatadogAgentlessScannerSnapshotAccess"
    effect = "Allow"
    actions = [
      // Allow reading created snapshots' blocks from EBS direct APIs
      "ebs:GetSnapshotBlock",
      "ebs:ListChangedBlocks",
      "ebs:ListSnapshotBlocks",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:*:*:snapshot/*",
    ]

    // Enforce that any of these actions can be performed on resources
    // (volumes and snapshots) that have the DatadogAgentlessScanner tag.
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/DatadogAgentlessScanner"
      values   = ["true"]
    }
  }

  statement {
    sid       = "DatadogAgentlessScannerDecryptEncryptedSnapshots"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:${data.aws_partition.current.partition}:kms:*:*:key/*"]

    // The following conditions enforce that decrypt action
    // can only be performed from calls by ebs API.
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "kms:EncryptionContextKeys"
      values   = ["aws:ebs:id"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["ec2.*.amazonaws.com"]
    }
  }

  statement {
    sid       = "DatadogAgentlessScannerKMSDescribe"
    effect    = "Allow"
    actions   = ["kms:DescribeKey"]
    resources = ["arn:${data.aws_partition.current.partition}:kms:*:*:key/*"]
  }

  statement {
    sid    = "DatadogAgentlessScannerGetLambdaDetails"
    effect = "Allow"
    actions = [
      "lambda:GetFunction",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:lambda:*:*:function:*"
    ]
    // Forbid scanning lambdas that does have a DatadogAgentlessScanner:false tag.
    condition {
      test     = "StringNotEquals"
      variable = "aws:ResourceTag/DatadogAgentlessScanner"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerECRAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "DatadogAgentlessScannerECRImages"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ecr:*:*:repository/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "ecr:ResourceTag/DatadogAgentlessScanner"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DatadogAgentlessScannerGetLambdaLayerDetails"
    effect = "Allow"
    actions = [
      "lambda:GetLayerVersion",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:lambda:*:*:layer:*:*"
    ]
    // Forbid scanning lambdas that does have a DatadogAgentlessScanner:false tag.
    condition {
      test     = "StringNotEquals"
      variable = "aws:ResourceTag/DatadogAgentlessScanner"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "scanning_worker_dspm_policy_document" {
  statement {
    sid    = "DatadogAgentlessScannerAccessS3Objects"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::*/*"
    ]
  }

  statement {
    sid    = "DatadogAgentlessScannerListS3Buckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::*"
    ]
  }

  statement {
    sid    = "DatadogAgentlessScannerDecryptS3Objects"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:kms:*:*:key/*"
    ]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.*.amazonaws.com"]
    }
  }
}

// Single policy merging all the above, for SaaS mode. Overriding merges the
// statements shared by the orchestrator and worker documents (same Sid).
data "aws_iam_policy_document" "scanning_policy_document" {
  override_policy_documents = concat(
    [
      data.aws_iam_policy_document.scanning_orchestrator_policy_document.json,
      data.aws_iam_policy_document.scanning_worker_policy_document.json,
    ],
    var.sensitive_data_scanning_enabled ? [data.aws_iam_policy_document.scanning_worker_dspm_policy_document.json] : [],
  )
}
