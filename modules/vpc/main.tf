locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
  public_cidr               = cidrsubnet(var.cidr, 3, 0)
  private_cidr              = cidrsubnet(var.cidr, 3, 4)
  ssm_vpc_endpoint_services = ["ec2messages", "ssmmessages", "ssm"]
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true # required for aws_vpc_endpoint
  enable_dns_hostnames = true # ditto

  tags = merge({ "Name" = var.name }, var.tags, local.dd_tags)
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({ "Name" = var.name }, var.tags, local.dd_tags)
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = local.public_cidr

  tags = merge({ "Name" = "${var.name}-public" }, var.tags, local.dd_tags)
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge({ "Name" = var.name }, var.tags, local.dd_tags)
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge({ "Name" = var.name }, var.tags, local.dd_tags)

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({ "Name" = "${var.name}-public" }, var.tags, local.dd_tags)
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = local.private_cidr

  tags = merge({ "Name" = "${var.name}-private" }, var.tags, local.dd_tags)
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({ "Name" = "${var.name}-private" }, var.tags, local.dd_tags)
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3" {
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = data.aws_vpc_endpoint_service.s3.service_type
  vpc_id            = aws_vpc.vpc.id
  route_table_ids   = [aws_route_table.public.id, aws_route_table.private.id]

  tags = merge(var.tags, local.dd_tags)
}

resource "aws_security_group" "endpoint_sg" {
  name        = "${var.name}-vpc-endpoints"
  description = "VPC endpoint security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  tags = merge(var.tags, local.dd_tags)

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_vpc_endpoint_service" "lambda" {
  service      = "lambda"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "lambda" {
  service_name        = data.aws_vpc_endpoint_service.lambda.service_name
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.lambda.service_type
  vpc_id              = aws_vpc.vpc.id
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, local.dd_tags)
}

data "aws_vpc_endpoint_service" "ebs" {
  service      = "ebs"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "ebs" {
  service_name        = data.aws_vpc_endpoint_service.ebs.service_name
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.ebs.service_type
  vpc_id              = aws_vpc.vpc.id
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, local.dd_tags)
}

data "aws_vpc_endpoint_service" "ssm" {
  for_each = toset(var.enable_ssm_vpc_endpoint ? local.ssm_vpc_endpoint_services : [])

  service      = each.value
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "ssm" {
  for_each = toset(var.enable_ssm_vpc_endpoint ? local.ssm_vpc_endpoint_services : [])

  service_name        = data.aws_vpc_endpoint_service.ssm[each.value].service_name
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.ssm[each.value].service_type
  vpc_id              = aws_vpc.vpc.id
  subnet_ids          = [aws_subnet.private.id]
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoint_sg.id]

  tags = merge(var.tags, local.dd_tags)
}
