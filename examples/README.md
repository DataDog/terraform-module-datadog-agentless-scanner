# AWS Examples

Pick a deployment mode first. Not sure which? See [Choose a deployment mode](../README.md#choose-a-deployment-mode-aws).

| Example | Mode | Use it when |
|---|---|---|
| [Datadog-hosted (SaaS)](saas/README.md) | Datadog-hosted | You don't want any scanner infrastructure in your account |
| [Single region](single_region/README.md) | Self-hosted | Getting started, or most of your hosts are in one region |
| [Multi region](multi_region/README.md) | Self-hosted | You have significant workloads in several regions |
| [Cross account](cross_account/README.md) | Self-hosted | One scanner account scans many AWS accounts |
| [Custom VPC](custom_vpc/README.md) | Self-hosted | Reuse an existing VPC |
| [Custom Agent configuration](custom_agent_configurations/README.md) | Self-hosted | Pass custom config to the Datadog Agent next to the scanners |

## Datadog-hosted (SaaS) mode

### Datadog-hosted (SaaS)

No scanner is deployed in your account. Datadog performs the scans from its own infrastructure by assuming your Datadog integration role. Terraform only creates one IAM managed policy with the scanning permissions and attaches it to that role.

Requires an AWS account already integrated with Datadog. AWS only.

To set it up, see the [**Datadog-hosted (SaaS) example**](saas/README.md).

## Self-hosted mode

All self-hosted examples need a Datadog API key with **Remote Configuration enabled**.

### Single region

One scanner deployment in one region, scanning every region in the account. Simplest setup and the right starting point. Scanning hosts in other regions means cross-region data transfer, which you pay for, so it gets expensive as your footprint outside the scanner's region grows.

See the [example](single_region/README.md).

### Multi region

Scanners deployed in several regions of the same account, so each region is scanned locally with no cross-region transfer. As a rule of thumb, deploy a scanner in any region with more than ~150 hosts: past that, cross-region transfer costs more than running a regional scanner (~$60/month).

<!-- TODO(PM): verify the 150-host rule matches public docs before publishing. -->

See the [example](multi_region/README.md).

### Cross account

The full scanner setup lives in one account. Every other account only gets a delegate role that lets the scanner in. Works with single or multi-region scanner deployments.

See the [example](cross_account/README.md).

### Custom VPC

Reuse one of your existing VPCs instead of letting the module create a new one.

See the [example](custom_vpc/README.md).

### Custom Agent configuration

Pass custom configuration to the Datadog Agent that runs alongside the scanners.

See the [example](custom_agent_configurations/README.md).
