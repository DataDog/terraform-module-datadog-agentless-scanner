## Description

The vpc module can be used to spawn a dedicated VPC specifically crafted for running the agentless scanner instance.

It provides dedicated private subnet, associated with the proper private endpoints to AWS services in order to reduce the network cost induced by scanning resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.endpoint_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_vpc_endpoint_service.ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_enable_ssm_vpc_endpoint"></a> [enable\_ssm\_vpc\_endpoint](#input\_enable\_ssm\_vpc\_endpoint) | Whether to enable AWS SSM VPC endpoint | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name tag, e.g stack | `string` | `"DatatogAgentlessScanner"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the instance/volume created | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nap_public_id"></a> [nap\_public\_id](#output\_nap\_public\_id) | The public IP associated with the VPC's NAT |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | The private subnets of the created VPC |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | The public subnets of the created VPC |
| <a name="output_routing_ready"></a> [routing\_ready](#output\_routing\_ready) | Indicates whether routing resources have been successfully provisioned |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | The VPC created for the Datadog agentless scanner |
<!-- END_TF_DOCS -->
