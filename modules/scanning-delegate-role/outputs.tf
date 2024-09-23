output "role" {
  description = "The scanning role created"
  value       = aws_iam_role.role
}

output "rds_assume_role" {
  description = "The scanning role created"
  value       = aws_iam_role.role
}

output "primary_kms_key" {
  description = "The primary KMS key ARN to encrypt the exported data"
  value       = aws_kms_key.agentless_kms_key
}

output "primary_kms_key_region" {
  description = "The region of the primary KMS key"
  value       = data.aws_region.current.name
}