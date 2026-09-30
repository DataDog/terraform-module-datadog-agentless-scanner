output "role" {
  description = "The scanning role created"
  value       = aws_iam_role.role
}

output "rds_service_role_arn" {
  description = "The ARN of the service role used by RDS to write the export to the S3 bucket"
  value       = length(aws_iam_role.rds_service_role) > 0 ? one(aws_iam_role.rds_service_role).arn : null
}

output "managed_policies" {
  description = "The customer managed policies attached to the scanning role"
  value = {
    scanning_policy     = module.scanning_policy.policy
    scanning_rds_policy = one(aws_iam_policy.scanning_rds_policy)
  }
}
