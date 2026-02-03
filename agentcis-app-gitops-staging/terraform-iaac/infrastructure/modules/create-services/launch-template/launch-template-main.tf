###### reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
locals {
  launch_templates_map = {
    for idx, name in var.launch_template_names : name => {
      ami_id               = var.launch_template_ami_ids[idx]
      instance_type        = var.launch_template_instance_types[idx]
      security_groups      = try(var.launch_template_security_groups[idx], [])
      iam_instance_profile = var.launch_template_iam_instance_profile[idx]
      user_data            = try(var.launch_template_user_data[idx], null)
    }
  }
}

resource "aws_launch_template" "main_launch_template_create" {
  for_each = local.launch_templates_map

  name                   = "(${var.project_name}-${var.environment})-${each.key}-template"
  image_id               = each.value.ami_id
  description            = "${each.key}-Terraform"
  instance_type          = each.value.instance_type
  key_name               = var.launch_template_instance_keypair
  ebs_optimized          = false
  update_default_version = true

  vpc_security_group_ids = each.value.security_groups

  # network_interfaces {
  #   associate_public_ip_address = true
  #   delete_on_termination       = true
  #   device_index                = 0
  #   security_groups = each.value.security_groups
  # }

  iam_instance_profile {
    name = each.value.iam_instance_profile
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${each.key}-template"
    creator     = var.creator
    project     = var.project_name
    environment = var.environment
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-${var.environment}-${each.key}"
      creator     = var.creator
      project     = var.project_name
      environment = var.environment
    }
  }

  user_data = each.value.user_data != null ? base64encode(each.value.user_data) : null
}