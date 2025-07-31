# main.tf
terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "my-terraform-test-bucket-1234567893"
  acl    = "private"
}
