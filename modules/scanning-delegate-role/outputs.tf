output "role" {
  description = "The scanning role created"
  value       = aws_iam_role.role
}

output "rds_service_role_arn" {
  description = "The ARN of the service role used by RDS to write the export to the S3 bucket"
  value       = aws_iam_role.role.arn
}

output "primary_kms_key" {
  description = "The primary KMS key ARN to encrypt the exported data"
  value       = aws_kms_key.agentless_kms_key[0].arn
}

output "primary_kms_key_region" {
  description = "The region of the primary KMS key"
  value       = data.aws_region.current.name
}
