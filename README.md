# AWS Infrastructure as Code

## Resources Managed
- IAM Users (Admin + GitHub Actions)
- ECR Repository with Lifecycle Policy
- IAM Access Keys with PGP Encryption

## Quick Start
1. Set Keybase username:
```bash
export TF_VAR_keybase_user="your_keybase_username"
```

2. Initialize Terraform:
```bash
terraform init
```

3. Import existing resources:
```bash
terraform import aws_iam_user.admin_user My-Admin
terraform import aws_iam_user.github_ecr github-ecr
terraform import aws_ecr_repository.test_push_image test-push-image
```

4. Apply configuration:
```bash
terraform apply
```

## Security Operations
- Rotate credentials:
```bash
terraform apply -replace=aws_iam_access_key.gh_ecr_key
```

- Decrypt secrets:
```bash
terraform output -raw gh_ecr_credentials | jq -r '.secret_access_key' | base64 -d | keybase pgp decrypt
```