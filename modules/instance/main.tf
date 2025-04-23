locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

resource "aws_launch_template" "launch_template" {
  name_prefix            = "DatadogAgentlessScannerLaunchTemplate"
  image_id               = var.instance_image_id
  instance_type          = var.instance_type
  user_data              = base64encode(var.user_data)
  vpc_security_group_ids = coalescelist(var.vpc_security_group_ids, [aws_security_group.default_scanner_security_group.id])
  key_name               = var.key_name

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = var.instance_root_volume_size
      volume_type           = "gp3"
    }
  }

  monitoring {
    enabled = var.monitoring
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  metadata_options {
    http_tokens = "required"
  }

  # Tag created instances, volumes and network interface at launch
  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])
    content {
      resource_type = tag_specifications.value
      tags = merge(
        var.tags,
        local.dd_tags,
        # add a Name tag for instances only
        tag_specifications.value == "instance" ? { "Name" = var.name } : {}
      )
    }
  }

  tags = merge(var.tags, local.dd_tags)
}

resource "aws_security_group" "default_scanner_security_group" {
  name_prefix = "datadog-agentless-scanner-sg"
  vpc_id      = var.vpc_id
  description = "Datadog Agentless Scanner default security group"
  tags        = merge(var.tags, local.dd_tags)

  ingress = []

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix      = "datadog-agentless-scanner-asg"
  min_size         = var.min_asg_size
  max_size         = var.max_asg_size
  desired_capacity = var.asg_size

  # references:
  #   - https://github.com/hashicorp/terraform-provider-aws/issues/29753
  #   - https://github.com/hashicorp/terraform-provider-aws/pull/32914
  ignore_failed_scaling_activities = true

  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  # Instances are terminated every 24 hours and recreated with latest AMI.
  # This allows automated upgrade of our instances baseline.
  max_instance_lifetime = 24 * 3600

  instance_refresh {
    strategy = "Rolling"
    preferences {
      # Whenever the launch template changes, allow replacing instances all at once
      min_healthy_percentage = 0
    }
  }

  # aws_autoscaling_group doesn't have a "tags" attribute, but instead a "tag" block
  dynamic "tag" {
    for_each = merge({ "Name" = "DatadogAgentlessScannerASG" }, var.tags, local.dd_tags)
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false # tagging is handled by the launch template, here we only tag the ASG itself
    }
  }

  lifecycle {
    replace_triggered_by = [aws_security_group.default_scanner_security_group]
  }
}
