# Changelog

## Version TBD

### Terraform

- Add missing CopySnapshot permissions to allow AMI scanning
- Create a dedicated security-group for scanner instead of relying on the VPC default one.
- Always rely on SecretsManager to store the Datadog API Key

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
