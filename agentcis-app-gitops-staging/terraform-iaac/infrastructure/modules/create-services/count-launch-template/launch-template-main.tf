###### reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
locals {
  template_count = length(var.launch_template_names)
}

resource "aws_launch_template" "main_launch_template_create" {
  count = local.template_count

  name                   = "(${var.project_name}-${var.environment})-${var.launch_template_names[count.index]}-template"
  image_id               = var.launch_template_ami_ids[count.index]
  description            = "${var.launch_template_names[count.index]}-Terraform"
  instance_type          = var.launch_template_instance_types[count.index]
  key_name               = var.launch_template_instance_keypair
  ebs_optimized          = false
  update_default_version = true

  vpc_security_group_ids = try(var.launch_template_security_groups[count.index], [])
  # network_interfaces {
  #   associate_public_ip_address = true
  #   delete_on_termination       = true
  #   device_index                = 0
  #   ######## sg yeaha map bhako xa hai
  #   security_groups = try(var.launch_template_security_groups[count.index], [])
  # }

  iam_instance_profile {
    name = var.launch_template_iam_instance_profile[count.index]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.launch_template_names[count.index]}-template"
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
      Name        = "${var.project_name}-${var.environment}-${var.launch_template_names[count.index]}"
      creator     = var.creator
      project     = var.project_name
      environment = var.environment
    }
  }

  user_data = try(base64encode(var.launch_template_user_data[count.index]), null)

  ######################### user-data -> individual start ###########################
  # user_data = base64encode(<<EOF
  #   #!/bin/bash
  #   echo "testing user data config for ${var.launch_template_names[count.index]}" >> /home/ubuntu/test.txt
  # EOF
  # )

  ######################## user-data => end ###########################
}