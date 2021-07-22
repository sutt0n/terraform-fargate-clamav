provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

data "aws_caller_identity" "current" {}

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

    # Anything in the bucket remaining is a virus, so
    # we'll just delete it after a week.
    expiration {
      days = 7
    }
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


data "template_file" "event_queue_policy" {
  template = file("templates/event_queue_policy.tpl.json")

  vars = {
    bucketArn = aws_s3_bucket.quarantine_bucket.arn
  }
}

resource "aws_sqs_queue" "clamav_event_queue" {
  name = "s3_clamav_event_queue"

  policy = data.template_file.event_queue_policy.rendered
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.quarantine_bucket.id

  queue {
    queue_arn = aws_sqs_queue.clamav_event_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_sqs_queue.clamav_event_queue
  ]
}
