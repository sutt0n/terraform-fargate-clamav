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

  lifecycle_rule {
    enabled = true

    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.quarantine_bucket.id

  queue {
    queue_arn = aws_sqs_queue.clamav_event_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket" "clean_bucket" {
  provider = aws.east
  bucket   = "clean-bucket"
  acl      = "private"

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}