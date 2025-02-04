#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <github_repo>"
  exit 1
fi

TARGET_REPO="$1"

# Option 1: Disable colors by setting the TF_CLI_ARGS environment variable
export TF_CLI_ARGS="-no-color"

echo "Extracting Terraform outputs..."
TF_OUTPUT=$(terraform output -json)

# Remove ANSI escape sequences (if any) from the output
TF_OUTPUT=$(echo "$TF_OUTPUT" | sed -E 's/\x1B\[[0-9;]*[mK]//g')

# Remove UTF-8 BOM if present
TF_OUTPUT="${TF_OUTPUT#$'\xef\xbb\xbf'}"

# If extra (non-JSON) text exists before the JSON starts, remove it.
if [[ "$TF_OUTPUT" != "{"* ]]; then
  TF_OUTPUT=$(echo "$TF_OUTPUT" | sed -n '/^{/,$p')
fi

# Trim any carriage returns and extra whitespace
TF_OUTPUT=$(echo "$TF_OUTPUT" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Debug output: length and raw output
echo "TF_OUTPUT length: ${#TF_OUTPUT}"
echo "Raw Terraform outputs:"
echo "$TF_OUTPUT"

# ------------------------------------------------------
# Extract the valid JSON portion from any appended logs
# We use a Python snippet to grab the first JSON object.
# ------------------------------------------------------
VALID_JSON=$(python3 -c "import sys, re; content=sys.stdin.read(); m=re.search(r'(\{.*\})', content, re.DOTALL); print(m.group(1)) if m else sys.exit(1)" <<< "$TF_OUTPUT")

if [ -z "$VALID_JSON" ]; then
  echo "Error: Could not extract valid JSON from Terraform output."
  exit 1
fi

if ! echo "$VALID_JSON" | jq empty >/dev/null 2>&1; then
  echo "Error: Extracted JSON is not valid."
  exit 1
fi

# Extract values
SECRET_ARN=$(echo "$VALID_JSON" | jq -r '.secret_arn.value')
ECR_REPO_URL=$(echo "$VALID_JSON" | jq -r '.repository_url.value')
AWS_ACCOUNT_ID=$(echo "$VALID_JSON" | jq -r '.aws_account_id.value')

echo "Secret ARN: $SECRET_ARN"
echo "ECR Repo URL: $ECR_REPO_URL"
echo "AWS Account ID: $AWS_ACCOUNT_ID"

echo "Updating GitHub secrets in repo '$TARGET_REPO'..."
gh secret set SECRET_ARN_DEV --body "$SECRET_ARN" -R "$TARGET_REPO"
gh secret set ECR_REPO_URL_DEV --body "$ECR_REPO_URL" -R "$TARGET_REPO"
gh secret set AWS_ACCOUNT_ID --body "$AWS_ACCOUNT_ID" -R "$TARGET_REPO"

echo "GitHub secrets updated successfully."
