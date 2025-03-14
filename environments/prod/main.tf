terraform {
  backend "s3" {
    bucket         = "my-tf-state-bootstrap"
    key            = "environments/prod/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

module "iam" {
  source    = "../../modules/iam"
  user_name = "github-ecr-prod"
}

module "ecr" {
  source    = "../../modules/ecr"
  repo_name = "test-push-image-prod"
}

module "secrets" {
  source             = "../../modules/secrets"
  secret_name        = "github-actions/ecr-credentials-prod"
  access_key_id      = module.iam.access_key_id
  secret_access_key  = module.iam.secret_access_key
  ecr_repo_url       = module.ecr.repository_url
}

data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "secret_arn" {
  value = module.secrets.secret_arn
}

output "repository_url" {
  value = module.ecr.repository_url
}
