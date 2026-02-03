############### reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
locals {
  instances_map = {
    for idx, name in var.instance_name : name => {
      instance_type        = var.instance_type[idx]
      ami_id               = var.ami_id[idx]
      subnet_id            = var.subnet_id[idx]
      root_volume_size_gb  = var.root_volume_size_gb[idx]
      security_group_id    = var.security_group_id[idx]
      iam_instance_profile = var.iam_instance_profile[idx]
      user_data            = try(var.user_data[idx], null)
    }
  }
}

resource "aws_instance" "ec2_instance" {
  for_each = local.instances_map

  key_name                    = var.ssh_key_name
  ami                         = each.value.ami_id
  subnet_id                   = each.value.subnet_id
  instance_type               = each.value.instance_type
  associate_public_ip_address = true
  security_groups             = [each.value.security_group_id]
  iam_instance_profile        = each.value.iam_instance_profile
  user_data                   = each.value.user_data

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = each.value.root_volume_size_gb
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # lifecycle {
  #   ignore_changes = [
  #     security_groups, subnet_id, associate_public_ip_address
  #   ]
  # }
  lifecycle {
    ignore_changes = [
      security_groups,
      associate_public_ip_address,
      iam_instance_profile, # Ignore IAM profile changes
      user_data,            # Ignore user_data changes (cloud-init, lifecycle scripts)
      tags,                 # Ignore tag changes (external management)
      #public_ip,                # Ignore public IP changes (elastic IP assignments)
      source_dest_check # Ignore source/dest check changes
    ]
  }

  tags = {
    Name        = "[${var.project_name}-${var.environment}]-${each.key}"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}
