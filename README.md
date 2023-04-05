# terraform-fargate-clamav
Repository for [an article](https://dev.to/sutt0n/scanning-files-with-clamav-on-aws-with-a-nodejs-fargate-sqs-consumer-with-terraform-5048) on scanning files with Terraform, Lambda, Fargate, Docker, S3, SQS, and ClamAV.

## Initialization

1. Run the `tf-setup.sh` script to set up the S3 bucket and DynamoDB lock table for terraform.
2. `terraform init`
3. `terraform apply`

## Testing

1. For testing both the valid and virus files, run `./test-virus.sh`
