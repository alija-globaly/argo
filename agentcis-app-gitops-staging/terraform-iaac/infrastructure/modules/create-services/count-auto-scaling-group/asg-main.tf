############# reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
locals {
  asg_count = length(var.asg_names)
}

resource "aws_autoscaling_group" "autoscaling_group" {
  count = local.asg_count

  name                = "[${var.project_name}-${var.environment}]-${var.asg_names[count.index]}-asg"
  vpc_zone_identifier = var.subnet_ids_list[count.index]

  # Use try() to handle optional target groups
  target_group_arns = try(var.target_group_arns_list[count.index], null)

  desired_capacity  = var.asg_ec2_desired_capacities[count.index]
  max_size          = var.asg_ec2_max_capacities[count.index]
  min_size          = var.asg_ec2_min_capacities[count.index]
  default_cooldown  = var.asg_default_cooldown
  health_check_type = var.asg_heathcheck_type

  # launch_template {
  #   id      = var.launch_template_ids[count.index]
  #   version = var.launch_template_versions[count.index]
  # }
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = var.launch_template_ids[count.index]
        version            = var.launch_template_versions[count.index]
      }

      # Override instance type - this overrides whatever is in the launch template
      override {
        instance_type = var.asg_instance_types[count.index]
      }
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  tag {
    key                 = "Name"
    value               = "[${var.project_name}-${var.environment}]-${var.asg_names[count.index]}-instance"
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