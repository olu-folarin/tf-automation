terraform {
  backend "s3" {
    bucket         = "your-tf-state-bucket"
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
  access_key_id      = module.iam.this.access_key_id
  secret_access_key  = module.iam.this.secret_access_key
  ecr_repo_url       = module.ecr.this.repository_url
}
