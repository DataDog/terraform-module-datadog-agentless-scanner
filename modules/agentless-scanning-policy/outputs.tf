output "policy" {
  description = "The customer managed policy granting Agentless Scanning permissions"
  value       = aws_iam_policy.policy
}
