# Single Region Example

With this option, a single Agentless scanner is deployed in a single region. Although this can incur more costs, as it requires each Agentless scanner to perform cross-region scans per account, Datadog recommends this option.

To deploy in a single regions you can check this [example](multi_region/README.md).

# Multi Region Example

With this option, Agentless scanners are deployed on a single cloud account and are distributed across multiple regions within the account. With this deployment model, Agentless scanners are granted visibility without needing to perform cross-region scans, which are expensive in practice.

To deploy in multiple regions you can check this [example](multi_region/README.md).

# Cross Account Example

With this option, Agentless scanner is deployed in a single or multi-region set-up on a single account.
You don't need to deploy the scanner in any of you other accounts, instead a single delegate role will be created that will allows the scanner access to that account.

If you are interested to scan your other accounts you can check that [example](cross_account/README.md)

# Custom VPC Example

If for any reasons you want to avoid creating a new VPC for the Agentless scanners and want to re-use one of your own you can check that [example](custom_vpc/README.md)
