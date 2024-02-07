# Changelog

## Terraform 0.8.0

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

## Terraform 0.7.0

### agentless-scanner 2024011701

- Execute Trivy scans in dedicated processes.

## Terraform 0.6.0

### agentless-scanner 2024011501

- Clean up downloaded AWS Lambdas on startup.
- Increase timeout while downloading AWS Lambda functions.

## Terraform 0.5.0

### agentless-scanner 2023122001

Initial private beta release.
