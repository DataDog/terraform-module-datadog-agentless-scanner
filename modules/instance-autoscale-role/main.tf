resource "aws_iam_role" "role" {
  name               = "DatadogAgentlessScannerAutoScalingWorkflowDelegateRole"
  assume_role_policy = data.aws_iam_policy_document.worflow_assume_role_policy.json

  inline_policy {
    name   = "AssumeRolePolicy"
    policy = data.aws_iam_policy_document.inline_policy.json
  }

  tags = {
    "DatadogAgentlessScanner" = "true"
    "Datadog"                 = "true"
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions   = ["autoscaling:SetDesiredCapacity"]
    resources = ["arn:${data.aws_partition.current.partition}:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/datadog-agentless-scanner-asg*"]
    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/DatadogAgentlessScanner"
      values   = ["true"]
    }
  }
}

data "aws_iam_policy_document" "worflow_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}
