#!/bin/bash
set -e

# This script syncs Terraform outputs from the current environment
# to GitHub repository secrets using the GitHub CLI.
# Usage: ./sync_github_secrets.sh <github_repo>
# Example: ./sync_github_secrets.sh your-org/your-app-repo

if [ -z "$1" ]; then
  echo "Usage: $0 <github_repo>"
  exit 1
fi

GITHUB_REPO="$1"

echo "Extracting Terraform outputs..."
TF_OUTPUT=$(terraform output -json)

if [ -z "$TF_OUTPUT" ]; then
  echo "Terraform output is empty. Make sure you have run 'terraform apply'."
  exit 1
fi

# Use jq to extract outputs
SECRET_ARN=$(echo "$TF_OUTPUT" | jq -r '.secret_arn.value')
ECR_REPO_URL=$(echo "$TF_OUTPUT" | jq -r '.ecr_repository_url.value')
AWS_ACCOUNT_ID=$(echo "$TF_OUTPUT" | jq -r '.aws_account_id.value')

echo "Updating GitHub secrets in repo '$GITHUB_REPO'..."

gh secret set SECRET_ARN_DEV --body "$SECRET_ARN" -R "$GITHUB_REPO"
gh secret set ECR_REPO_URL_DEV --body "$ECR_REPO_URL" -R "$GITHUB_REPO"
gh secret set AWS_ACCOUNT_ID --body "$AWS_ACCOUNT_ID" -R "$GITHUB_REPO"

echo "GitHub secrets updated successfully."
