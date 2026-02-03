############## reference https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "main_security_group" {
  name        = "[${var.project_name}-${var.environment}]-${var.sg_name}-sg"
  description = var.description
  vpc_id      = var.vpc_id

  # TCP ingress rules
  dynamic "ingress" {
    for_each = [for i in range(length(var.sg_ingress_ports)) : {
      port = var.sg_ingress_ports[i]
      cidr = var.sg_ingress_cidrs[i]
    }]
    content {
      from_port   = tonumber(split("-", ingress.value.port)[0])
      to_port     = tonumber(split("-", ingress.value.port)[length(split("-", ingress.value.port)) - 1])
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
      description = "allow-tcp-${ingress.value.port}"
    }
  }

  # UDP ingress rules (same ports as TCP)
  dynamic "ingress" {
    for_each = [for i in range(length(var.sg_ingress_ports)) : {
      port = var.sg_ingress_ports[i]
      cidr = var.sg_ingress_cidrs[i]
    }]
    content {
      from_port   = tonumber(split("-", ingress.value.port)[0])
      to_port     = tonumber(split("-", ingress.value.port)[length(split("-", ingress.value.port)) - 1])
      protocol    = "udp"
      cidr_blocks = [ingress.value.cidr]
      description = "allow-udp-${ingress.value.port}"
    }
  }

  # ICMP ingress rule
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_icmp_cidr]
    description = "allow-icmp"
  }

  # Egress (only define once!)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow-all-egress"
  }

  tags = {
    Name        = "[${var.project_name}-${var.environment}]-${var.sg_name}-sg"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }

  lifecycle {
    prevent_destroy       = false
    create_before_destroy = false
    ignore_changes        = [tags]
  }
}

#######################################################
# resource "aws_security_group" "main_security_group" {
#   name        = "[${var.project_name}-${var.environment}]-${var.sg_name}-sg"
#   description = var.description
#   vpc_id      = var.vpc_id

#   # Create ingress rules based on ports and corresponding CIDRs
#   dynamic "ingress" {
#     for_each = [for i in range(length(var.sg_ingress_ports)) : {
#       port = var.sg_ingress_ports[i]
#       cidr = var.sg_ingress_cidrs[i]
#     }]
#     content {
#       # from_port   = ingress.value.port
#       # to_port     = ingress.value.port   
#       from_port   = tonumber(split("-", ingress.value.port)[0])
#       to_port     = tonumber(split("-", ingress.value.port)[length(split("-", ingress.value.port)) - 1])
#       protocol    = "tcp"
#       cidr_blocks = [ingress.value.cidr]
#       description = "allow-port-${ingress.value.port}"
#     }
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "allow-all-egress"
#   }

#   tags = {
#     Name        = "[${var.project_name}-${var.environment}]-${var.sg_name}-sg"
#     project     = var.project_name
#     creator     = var.creator
#     environment = var.environment
#   }

#   lifecycle {
#     prevent_destroy       = false
#     create_before_destroy = false
#     ignore_changes        = [tags]
#   }
# }
