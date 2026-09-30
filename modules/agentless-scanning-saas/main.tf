module "scanning_policy" {
  source = "../agentless-scanning-policy"

  role_name                       = var.datadog_integration_role
  sensitive_data_scanning_enabled = var.sensitive_data_scanning_enabled
  policy_path                     = var.iam_policy_path
}
