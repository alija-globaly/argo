########## reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

resource "aws_iam_role" "main_aws_load_balancer_controller_role" {
  name        = "${var.project_name}-${var.environment}-K8s-EC2-IRSA-role"
  path        = "/"
  description = "IAM role for AWS Load Balancer Controller with EC2 trust relationship"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-K8s-EC2-IRSA-role"
    creator     = var.creator
    environment = var.environment
    project     = var.project_name
  }
}

# Create an instance profile for EC2 instances
resource "aws_iam_instance_profile" "main_aws_load_balancer_controller_profile" {
  name = "${var.project_name}-${var.environment}-K8s-EC2-IRSA-role-profile"
  role = aws_iam_role.main_aws_load_balancer_controller_role.name

  tags = {
    Name        = "${var.project_name}-${var.environment}-K8s-EC2-IRSA-role-profile"
    creator     = var.creator
    environment = var.environment
    project     = var.project_name
  }
}
