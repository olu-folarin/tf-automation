# tf-automation

This repository is designed to manage AWS infrastructure using Terraform for separate environments (dev and prod) while automating the synchronization of critical outputs into GitHub repository secrets for CI/CD.

## Repository Structure

- **environments/**
  - **dev/**: Contains Terraform configuration for the development environment.
  - **prod/**: Contains Terraform configuration for the production environment.
- **modules/**
  - **iam/**: Terraform module to manage IAM users and policies.
  - **ecr/**: Terraform module to manage AWS ECR repositories.
  - **secrets/**: Terraform module to manage and expose Secrets Manager secrets (e.g., secret ARN).
- **.github/workflows/**
  - **auto_sync.yml**: GitHub Actions workflow that runs Terraform commands and then executes the sync script to update GitHub repository secrets.
- **sync_github_secrets.sh**
  - A shell script that extracts Terraform outputs (like AWS account ID, ECR repository URL, and secret ARN), cleans up the JSON output, and uses the GitHub CLI to update secrets in a target repository.

## Automation Workflow

1. **Terraform Execution:**
   - Runs in each environment (dev/prod) to provision AWS resources.
   - Outputs such as `aws_account_id`, `repository_url`, and `secret_arn` are defined in the environment configuration files.

2. **Secrets Synchronization:**
   - The workflow in `.github/workflows/auto_sync.yml` initializes Terraform and applies the configuration.
   - After applying, it invokes `sync_github_secrets.sh` which cleans and parses the Terraform outputs, then updates the corresponding secrets in the target repository using the GitHub CLI.

3. **Integration Benefits:**
   - Automatically keeping the target repository's secrets up-to-date with the latest infrastructure configuration.
   - Reducing manual intervention and potential human errors in maintaining CI/CD credentials.

## Configuration Requirements

Before running the automation, ensure that the following secrets are configured in the tf-automation repository settings:

- `TF_STATE_BUCKET` – The S3 bucket used for Terraform state storage.
- `AWS_REGION` – Your AWS region (e.g. "eu-west-2").
- `DYNAMODB_TABLE` – The DynamoDB table used for state locking.
- `PAT_FOR_WORKFLOW` – Personal Access Token for GitHub, used as `GITHUB_TOKEN` in workflows.
- `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` – AWS credentials with permissions to access the backend resources.
- `TARGET_GITHUB_REPO` – Repository where CI/CD secrets are updated.

Additionally, it's recommended to set:

- `TF_CLI_ARGS` to `-no-color` to disable colored output from Terraform, ensuring that JSON outputs are clean.

## Usage Notes

- **Terraform:** Manage AWS resources using the modular configurations in `environments/` and `modules/`.
- **GitHub Actions Workflow:** The `.github/workflows/auto_sync.yml` workflow automatically applies Terraform and then synchronizes outputs as GitHub secrets.
- **Sync Script:** The `sync_github_secrets.sh` script handles parsing the Terraform outputs (with debugging for non-JSON text, ANSI escape sequences, BOMs, etc.) and updating the target repository using the GitHub CLI.

## Security and Best Practices

- Ensure AWS credentials provided have minimal permissions required.
- Store all sensitive parameters as protected repository secrets.
- Automate synchronization to reduce human error and keep production CI/CD pipelines secure.

This setup streamlines the infrastructure management and CI/CD integration by bridging Terraform outputs with the operational environments that require these credentials.