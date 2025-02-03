variable "secret_name" {
  type = string
}

variable "access_key_id" {
  type = string
}

variable "secret_access_key" {
  type = string
}

variable "ecr_repo_url" {
  type = string
}

resource "aws_secretsmanager_secret" "this" {
  name        = var.secret_name
  description = "ECR credentials for CI/CD"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id    = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    access_key_id     = var.access_key_id,
    secret_access_key = var.secret_access_key,
    ecr_repo_url      = var.ecr_repo_url
  })
}
