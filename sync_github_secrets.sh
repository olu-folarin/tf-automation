#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <github_repo>"
  exit 1
fi

TARGET_REPO="$1"

echo "Extracting Terraform outputs..."
TF_OUTPUT=$(terraform output -json)

if [[ "$TF_OUTPUT" != "{"* ]]; then
  TF_OUTPUT=$(echo "$TF_OUTPUT" | sed -n '/^{/,$p')
fi

TF_OUTPUT=$(echo "$TF_OUTPUT" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Debug output: length and raw JSON
echo "TF_OUTPUT length: ${#TF_OUTPUT}"
echo "Raw Terraform outputs:"
echo "$TF_OUTPUT"

if [ -z "$TF_OUTPUT" ]; then
  echo "Error: Terraform output is empty."
  exit 1
fi

if ! echo "$TF_OUTPUT" | jq empty >/dev/null 2>&1; then
  echo "Error: Terraform output is not valid JSON."
  exit 1
fi

SECRET_ARN=$(echo "$TF_OUTPUT" | jq -r '.secret_arn.value')
ECR_REPO_URL=$(echo "$TF_OUTPUT" | jq -r '.repository_url.value')
AWS_ACCOUNT_ID=$(echo "$TF_OUTPUT" | jq -r '.aws_account_id.value')

echo "Secret ARN: $SECRET_ARN"
echo "ECR Repo URL: $ECR_REPO_URL"
echo "AWS Account ID: $AWS_ACCOUNT_ID"

echo "Updating GitHub secrets in repo '$TARGET_REPO'..."
gh secret set SECRET_ARN_DEV --body "$SECRET_ARN" -R "$TARGET_REPO"
gh secret set ECR_REPO_URL_DEV --body "$ECR_REPO_URL" -R "$TARGET_REPO"
gh secret set AWS_ACCOUNT_ID --body "$AWS_ACCOUNT_ID" -R "$TARGET_REPO"

echo "GitHub secrets updated successfully."
