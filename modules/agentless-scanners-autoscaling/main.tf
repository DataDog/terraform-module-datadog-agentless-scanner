data "aws_partition" "current" {}

resource "aws_iam_role_policy" "agentless_autoscaling_policy" {
  name   = "DatadogAgentlessScannerAutoscalingPolicy"
  role   = var.datadog_integration_role
  policy = data.aws_iam_policy_document.agentless_autoscaling_policy_document.json

}

data "aws_iam_policy_document" "agentless_autoscaling_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:StartInstanceRefresh",
      "autoscaling:SetDesiredCapacity",
      "ec2:GetConsoleOutput",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:autoscaling:*:*:autoScalingGroup:*",
      "arn:${data.aws_partition.current.partition}:ec2:*:*:instance/*",
    ]
    // Enforce that any of these actions can be performed on resources
    // that have the DatadogAgentlessScanner tag.
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/DatadogAgentlessScanner"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
    ]
    resources = ["*"]
  }
}
