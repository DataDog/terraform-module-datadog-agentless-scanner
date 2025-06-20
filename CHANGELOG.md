# Changelog

## Version 0.11.11 - 2025-06-16

- Adapt CopySnapshot policy to latest IAM changes requiring both source and destination statements
- Use t4g.medium instance type for Agentless ec2 instances
- Remove unnecessary ec2:CopyImage permission

## Version 0.11.10 - 2025-04-24

- aws: add autoscaling module allowing the automated auto-scaling of scanners
- azure/arm: upgrade az bicep version
- azure/arm: call Agentless API on deployment

## Version 0.11.9 - 2025-02-14

- Azure: expose vnet_cidr parameter in main module

## Version 0.11.8 - 2025-02-12

- Use Ubuntu 24.04 Minimal Server image on AWS and Azure
- Run unattended upgrade on deployment on AWS and Azure
- Remove semgrep dependency
- Fix delegate role assignment on Azure Resource Manager
- Fix hostname on Azure Resource Manager

## Version 0.11.7 - 2024-12-10

- Add support for AWS ECR registry scanning
- Add support for scanning AWS RDS databases
- Add sensitive_data_scanning_rds_enabled parameter to opt-in to AWS RDS databases scanning
- Add S3 module to create a bucket used by the scanner to store temporary files (example: RDS exports)

## Version 0.11.6 - 2024-10-28

- Prevent Datadog Agent from starting before its configuration has been changed

## Version 0.11.5 - 2024-10-16

- Scanner role delegations based on a account_id wildcard by default: variable `account_roles` is now optional and defaults to allowing all accounts. This was done to simplify the cross-account setups.
- Scanner role delegations can be limited to a specific list of organizational unit paths via the `account_org_paths` variable. This can be used to restrict the scanner to only scan resources in specific organizational units.

## Version 0.11.4

- Add parameters `instance_type` and `instance_count` to configure the auto-scaling group properties
- Fix allowing overriding conflicting parameters (hostname, api_key, site) from agent_configuration variable

## Version 0.11.3

- Add permissions to copy AMIs (ec2:CopyImage) to improve coverage of cross-account AMI scanning
- Fix permissions to be able to scan for volumes encrypted with a customer-managed key

## Version 0.11.2

- Adds a scanner_channel variable at the root module level to allow specifying the channel to install the agentless scanner from
- Upgrade datadog-agent to version 7.53
- Add permissions to be able to scan for Lambda layers
- Add sensitive_data_scanning_enabled parameter to opt-in to DSPM scanning
- Add validation to api_key_secret_arns to be non-empty
- Add parameters to allow specififying custom configuration for the agent and scanner

## Version 0.11.1

- Allow auto-update of the agentless scanner package

## Version 0.11.0

- Encrypted snapshots: allow granting KMS keys for AWS resources (#79) [Pierre Guilleminot]

## Version 0.10.0

### Terraform

- Add IAM permission to allow decrypting snapshots using CMK (#71)
- Add missing CopySnapshot permissions to allow AMI scanning
- Create a dedicated security-group for scanner instead of relying on the VPC default one.
- Always rely on SecretsManager to store the Datadog API Key
- Add subnets per Availability Zone to the scanner

### CloudFormation

- Allow deploying scanner inside an existing VPC with the new optional parameters: `ScannerVPCId` and `ScannerSubnetId`
- Allow associating an existing security-group to the scanner with the new optional parameter: `ScannerSecurityGroupId`
- Allow attaching an existing SSH key-pair to the scanner with the new optional parameter: `ScannerSSHKeyPairName`
- Allow setting the Datadog API Key via SecretManager with thew new optional paramater: `DatadogAPIKeySecretArn`
- Creating a dedicated security-group by default with empty ingress rules
- Add support for offline mode to scan without remote-config (deactived by default)
- AutoScalingGroup update policy replacing instances as the launch template is being updated
- Remove `agent_version` and `scanner_version` from main module to favor pinned version
- Always rely on SecretsManager to store the Datadog API Key

## Version 0.9.1

- Adds missing nbd module activation in cloud init

## Version 0.9.0

### agentless-scanner 2024022201

- Add support for scanning containers (containerd and Docker activated by default)
- Add support for scanning AMIs
- Add support for scanning containers app
- Activate scanner for vulnerabilities for Java JARs in Lambdas
- Rely on Network Block Devices (NBD) for mounting EBS volumes
- Split agentless binary in dedicated package
- Improve performance of OS SBOMs generation

## Version 0.8.0

### agentless-scanner 2024020101

- Bump Trivy to version 2023-12-19.
- Fix detection of Linux distributions.
- Fix listing of packages on RPM distributions.
- Various fixes on container scanning (still disabled by default):
    - Fix Docker metadata
    - Reduce size of mount overlay options to be less that pagesize
    - Explicit error message on non supported storage drivers
- AWS: tag created resources with DatadogAgentlessScannerHostOrigin containing the hostname of the scanner
- AWS: reduce the number of ec2:DescribeSnapshot requests by batching poll requests
- AWS volume attach: fix selecting the next available XEN device
- AWS volume attach: reduce the number of DeleteVolume requests when cleaning up a scan
- NBD attach: fix occasional crashes when closing the NBD server

## Version 0.7.0

### agentless-scanner 2024011701

- Execute Trivy scans in dedicated processes.

## Version 0.6.0

### agentless-scanner 2024011501

- Clean up downloaded AWS Lambdas on startup.
- Increase timeout while downloading AWS Lambda functions.

## Version 0.5.0

### agentless-scanner 2023122001

Initial private beta release.
