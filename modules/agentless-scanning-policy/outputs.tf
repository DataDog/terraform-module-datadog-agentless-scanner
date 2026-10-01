output "json" {
  description = "Single IAM policy document granting all Agentless Scanning permissions (SaaS mode)"
  value       = data.aws_iam_policy_document.scanning_policy_document.json
}

output "orchestrator_json" {
  description = "IAM policy document for the scanning orchestrator (self-hosted mode)"
  value       = data.aws_iam_policy_document.scanning_orchestrator_policy_document.json
}

output "worker_json" {
  description = "IAM policy document for the scanning worker (self-hosted mode)"
  value       = data.aws_iam_policy_document.scanning_worker_policy_document.json
}

output "dspm_json" {
  description = "IAM policy document for the scanning of S3 buckets (self-hosted mode)"
  value       = data.aws_iam_policy_document.scanning_worker_dspm_policy_document.json
}
