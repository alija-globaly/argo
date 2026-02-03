############# reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
locals {
  asg_map = {
    for idx, name in var.asg_names : name => {
      subnet_ids          = var.subnet_ids_list[idx]
      target_group_arns   = try(var.target_group_arns_list[idx], null)
      desired_capacity    = var.asg_ec2_desired_capacities[idx]
      max_size            = var.asg_ec2_max_capacities[idx]
      min_size            = var.asg_ec2_min_capacities[idx]
      launch_template_id  = var.launch_template_ids[idx]
      launch_template_ver = var.launch_template_versions[idx]
      instance_type       = var.asg_instance_types[idx]
    }
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  for_each = local.asg_map

  name                = "[${var.project_name}-${var.environment}]-${each.key}-asg"
  vpc_zone_identifier = each.value.subnet_ids
  target_group_arns   = each.value.target_group_arns

  desired_capacity  = each.value.desired_capacity
  max_size          = each.value.max_size
  min_size          = each.value.min_size
  default_cooldown  = var.asg_default_cooldown
  health_check_type = var.asg_heathcheck_type

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = each.value.launch_template_id
        version            = each.value.launch_template_ver
      }

      # Override instance type - this overrides whatever is in the launch template
      override {
        instance_type = each.value.instance_type
      }
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  tag {
    key                 = "Name"
    value               = "[${var.project_name}-${var.environment}]-${each.key}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "creator"
    value               = var.creator
    propagate_at_launch = true
  }

  tag {
    key                 = "project"
    value               = var.project_name
    propagate_at_launch = true
  }
}