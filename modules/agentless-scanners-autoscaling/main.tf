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
      "autoscaling:DescribeAutoScalingGroups",
      "ec2:GetConsoleOutput",
    ]
    resources = ["*"]
    // Enforce that any of these actions can be performed on resources
    // that have the DatadogAgentlessScanner tag.
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/DatadogAgentlessScanner"
      values   = ["true"]
    }
  }
}
