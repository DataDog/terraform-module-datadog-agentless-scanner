output "json" {
  description = "The IAM policy document granting Agentless Scanning permissions, to be used in a customer managed policy"
  value       = data.aws_iam_policy_document.scanning_policy_document.json
}
