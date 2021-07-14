provider "aws" {
  region = "us-east-1"
  alias = "east"
}

resource "aws_s3_bucket" "av_quarantine_bucket" {
  provider = aws.east
  bucket   = "clamav-quarantine-bucket"
  acl      = "private"

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  lifecycle_rule {
    enabled = true

    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket" "clamav_clean_bucket" {
  provider = aws.east
  bucket   = "clamav-clean-bucket"
  acl      = "private"

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}