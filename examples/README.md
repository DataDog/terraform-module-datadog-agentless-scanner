# Single Region Example

With this option, a single Agentless scanner is deployed in a single region. Datadog recommends this option. However, this option can incur higher costs, as it requires each Agentless scanner to perform cross-region scans per account.

To deploy in a single region, see the [example](single_region/README.md).

# Multi Region Example

With this option, Agentless scanners are deployed on a single cloud account and are distributed across multiple regions within the account. With this deployment model, Agentless scanners are granted visibility without needing to perform cross-region scans, which are expensive in practice.

To deploy in multiple regions, see the [example](multi_region/README.md).

# Cross Account Example

With this option, an Agentless scanner is deployed in a single or multi-region set-up on a single account.
You don't need to deploy the scanner in any of your other accounts. Instead, a single delegate role is created that allows the scanner access to that account.

To scan across accounts, see the [example](cross_account/README.md)

# RDS Scanning Example

With this option, you can enable Agentless scanning for RDS databases. The scanner exports RDS snapshots to S3 and scans them for sensitive data without directly accessing your live databases.

To enable RDS scanning, see the [example](rds_scanning/README.md)

# Custom VPC Example

If you want to avoid creating a new VPC for the Agentless scanners, and you want to reuse one of your own, see the [example](custom_vpc/README.md)

# Custom Agent Configurations Example

If you want to add custom configurations for our Datadog Agent running alongside our scanners, see the [example](custom_agent_configurations/README.md)
