provider "aws" {
  region = "us-east-1"
  alias = "east"
}

resource "aws_s3_bucket" "quarantine_bucket" {
  provider = aws.east
  bucket   = "quarantine-bucket"
  acl      = "private"

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  tags = {
    environment = var.environment
  }

  lifecycle_rule {
    enabled = true

    expiration {
      days = 7
    }
  }
}