terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# KMS Key para cifrado (CMK)
resource "aws_kms_key" "s3_encryption" {
  description             = "CMK for S3 bucket encryption"
  deletion_window_in_days = 10
}

# Bucket para logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-log-bucket-example-unique-123"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.s3_encryption.arn
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Bucket principal
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-example-123"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "access-logs/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.s3_encryption.arn
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Bloqueo de acceso público
resource "aws_s3_bucket_public_access_block" "my_bucket_block" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
