output "role" {
  description = "The scanning role created"
  value       = aws_iam_role.role
}

output "rds_service_role_arn" {
  description = "The ARN of the service role used by RDS to write the export to the S3 bucket"
  value       = length(aws_iam_role.rds_service_role) > 0 ? one(aws_iam_role.rds_service_role).arn : null
}
