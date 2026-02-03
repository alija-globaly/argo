############## Reference : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "main_github_actions_role" {
  name = "${var.project_name}-${var.environment}-github-actions-AWS-ECR-S3-IRSA-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              for repo in var.github_repositories : "repo:${repo}:*"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-IRSA-github-actions-role"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}

# Attach AWS Managed Policies
locals {
  github_actions_policies = [
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicPowerUser",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  ]
}

resource "aws_iam_role_policy_attachment" "github_actions_policies" {
  for_each = toset(local.github_actions_policies)

  role       = aws_iam_role.main_github_actions_role.name
  policy_arn = each.value
}