############### reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "ec2_instance" {
  count = length(var.instance_name)

  key_name                    = var.ssh_key_name
  ami                         = var.ami_id[count.index]
  subnet_id                   = var.subnet_id[count.index]
  instance_type               = var.instance_type[count.index]
  associate_public_ip_address = true
  security_groups             = [var.security_group_id[count.index]]
  iam_instance_profile        = var.iam_instance_profile[count.index]
  #user_data                   = var.user_data[count.index]
  user_data = try(var.user_data[count.index], null)

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = var.root_volume_size_gb[count.index]
    volume_type           = "gp3"
    delete_on_termination = true
  }
  lifecycle {
    ignore_changes = [
      security_groups, subnet_id, associate_public_ip_address
    ]
  }

  # lifecycle {
  #   ignore_changes = [
  #     instance_type, security_groups, subnet_id, associate_public_ip_address
  #   ]
  # }

  tags = {
    Name        = "[${var.project_name}-${var.environment}]-${var.instance_name[count.index]}"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}
