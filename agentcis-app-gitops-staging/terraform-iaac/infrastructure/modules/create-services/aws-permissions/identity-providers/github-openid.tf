data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  tags = {
    Name        = "${var.project_name}-${var.environment}-github-oidc-provider"
    project     = var.project_name
    creator     = var.creator
    environment = var.environment
  }
}