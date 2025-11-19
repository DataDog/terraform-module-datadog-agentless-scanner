# RDS Scanning Example

This folder shows an example of Terraform code to deploy the necessary resources to perform Agentless scanning on RDS databases.
This example enables RDS scanning in two different AWS regions: `us-east-1` and `eu-central-1`.

The TF code in this example uses the [agentless-s3-bucket module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner/modules/agentless-s3-bucket)
to deploy the necessary artifacts to perform RDS scanning in the two specified regions, as well as the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner) 
to deploy a Datadog Agentless scanner in multiple regions in your [AWS](https://aws.amazon.com/) account.

The `scanning-delegate-role` and `agentless-scanner-role` modules, which create IAM resources, are only created once, as IAM is a global service. You can thus use any regional provider to create the modules.

## Quick start

To deploy a Datadog agentless scanner:

1. Run `terraform init`.
1. Run `terraform apply`.
1. Set your Datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/).

## How RDS Sensitive Data Scanning Works

The Datadog Agentless Scanner supports sensitive data scanning for RDS databases using a **two-stage process** that never directly accesses your live databases. The scanner is piloted by the Datadog backend and orchestrates the entire scanning workflow automatically.

### Stage 1: Scanner Initiates RDS Export

The Agentless Scanner, controlled by the Datadog backend, initiates an RDS snapshot export to S3:

1. **Datadog backend identifies** RDS databases to scan based on your configuration and tags
2. **Scanner receives instructions** from the Datadog backend to export a specific RDS snapshot
3. **Scanner calls AWS RDS API** (`rds:StartExportTask`) to export the snapshot to a dedicated S3 bucket
4. **AWS RDS exports the snapshot** to S3 in Parquet format, encrypted with a KMS key managed by the scanner
5. **Export completes** and data is ready for scanning in the S3 bucket

The scanner uses a dedicated RDS service role (`DatadogAgentlessScannerRDSS3ExportRole`) that has permissions to write exports to the Agentless Scanner's S3 bucket.

### Stage 2: Scanner Scans Exported Snapshot

Once the export completes, the scanner automatically proceeds to scan the exported data:

1. **Scanner assumes the delegate role** to gain read-only access to the S3 bucket
2. **Reads the exported Parquet files** from S3
3. **Performs sensitive data scanning** on the exported database content
4. **Sends scan results** to Datadog for analysis and alerting
5. **Exported files are automatically deleted**

### Architecture

### Key Components

- **Datadog Backend**: Orchestrates and controls the scanner, determining which RDS databases to scan and when
- **Agentless Scanner**: EC2 instance that initiates RDS exports and performs the actual scanning
- **S3 Bucket** (`datadog-agentless-scanning-*`): Temporary storage for RDS exports with automatic 2-day expiration
- **RDS Service Role**: Allows AWS RDS service to write exports to the S3 bucket
- **Delegate Role**: Allows the scanner to read from the S3 bucket and initiate RDS exports
- **KMS Key**: Encrypts all exported data at rest

### Security Features

- **No Direct Database Access**: Scanners never connect to live RDS databases
- **Backend-Controlled**: All scanning operations are orchestrated by Datadog backend, not manually triggered
- **Encryption**: All exports are encrypted with KMS at rest and in transit
- **Automatic Cleanup**: Exported files are automatically deleted
- **Least Privilege**: Separate IAM roles with minimal required permissions
- **Tag-Based Control**: Only RDS resources without `DatadogAgentlessScanner:false` tag are eligible for scanning

### Requirements

- RDS databases must have automated backups enabled (which creates snapshots)
- RDS databases should not have the `DatadogAgentlessScanner:false` tag if you want them to be scanned
- S3 bucket must be deployed in the same region as the RDS database to minimize data transfer costs
- The scanner must be deployed in the same region as the RDS databases you want to scan
