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
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.key_name

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = var.instance_root_volume_size
      volume_type           = "gp2"
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

resource "aws_autoscaling_group" "asg" {
  name             = "datadog-agentless-scanner-asg"
  min_size         = var.asg_size
  max_size         = var.asg_size
  desired_capacity = var.asg_size

  vpc_zone_identifier = [var.subnet_id]

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
}
