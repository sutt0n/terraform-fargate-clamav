#!/bin/bash -e

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

echo ${AWS_ACCOUNT_ID}

# shellcheck disable=SC2091
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"

docker build -t "clamav" -f ./Dockerfile .
docker tag "clamav" "${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/fargate-images:latest"
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/fargate-images"