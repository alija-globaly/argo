resource "aws_iam_policy" "main_aws_ecr_allow_policy" {
  name        = "${var.project_name}-${var.environment}-K8S-AWS-ECR-Secret-Manager-CW-allow-policy"
  path        = "/"
  description = "Comprehensive IAM policy for ECR (public/private), S3, and Secrets Manager access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR Private Registry - Full Access
      {
        Sid    = "ECRPrivateFullAccess"
        Effect = "Allow"
        Action = [
          "ecr:*"
        ]
        Resource = "*"
      },
      # ECR Public Registry - Full Access
      {
        Sid    = "ECRPublicFullAccess"
        Effect = "Allow"
        Action = [
          "ecr-public:*"
        ]
        Resource = "*"
      },
      # STS for ECR Public
      {
        Sid    = "STSForECRPublic"
        Effect = "Allow"
        Action = [
          "sts:GetServiceBearerToken"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "ecr-public.amazonaws.com"
          }
        }
      },
      # Secrets Manager Read/Write
      {
        Sid    = "SecretsManagerReadWrite"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:CancelRotateSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:UpdateSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetRandomPassword",
          "secretsmanager:ListSecrets",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource"
        ]
        Resource = "*"
      },
      # S3 Full Access
      {
        Sid    = "S3FullAccess"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },
      # EC2 Full Access
      {
        Sid    = "EC2FullAccess"
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      },
      # CloudWatch Logs for ECR Image Builder
      {
        Sid    = "CloudWatchLogsForImageBuilder"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/imagebuilder/*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-K8S-AWS-ECR-Secret-Manager-CW-allow-policy"
    creator     = var.creator
    environment = var.environment
    project     = var.project_name
  }
}