#!/bin/bash

# Create S3 Bucket
MY_ARN=$(aws iam get-user --query User.Arn --output text 2>/dev/null)
aws s3 mb "s3://tf-clamav-state" --region "us-east-1"
sed -e "s/RESOURCE/arn:aws:s3:::tf-clamav-state/g" -e "s/KEY/terraform.tfstate/g" -e "s|ARN|${MY_ARN}|g" "$(dirname "$0")/templates/s3_policy.json" > new-policy.json
aws s3api put-bucket-policy --bucket "tf-clamav-state" --policy file://new-policy.json
aws s3api put-bucket-versioning --bucket "tf-clamav-state" --versioning-configuration Status=Enabled
rm new-policy.json

# Create DynamoDB Table
aws dynamodb create-table \
  --table-name "tf-dynamodb-lock" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
  --region "us-east-1"