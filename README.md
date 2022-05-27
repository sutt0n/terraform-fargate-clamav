# terraform-fargate-clamav
Repository for my article on scanning files with Terraform, Lambda, Fargate, Docker, S3, SQS, and ClamAV.

## Initialization

1. Run the `tf-setup.sh` script to set up the S3 bucket and DynamoDB lock table for terraform.
2. `terraform init`
3. `terraform apply`

## Testing

1. For testing the valid file `npm run test:valid`
2. For testing the virus file `npm run test:virus`