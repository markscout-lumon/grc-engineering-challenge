terraform {
  required_version = ">= 1.6"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" {
  region = var.region

  # (CM-6): add a default_tags block so every taggable resource carries
  # Project, Environment, ManagedBy, and ComplianceScope automatically.
  default_tags {
    tags = {
      Project     = "grc-challenge"
      Environment = "test"
      ManagedBy   = "GRC"
      ComplianceScope = "NIST 800-53"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  primary_name = "${var.project_name}-${var.environment}-data-${random_id.suffix.hex}"
  log_name     = "${var.project_name}-${var.environment}-logs-${random_id.suffix.hex}"
}

#Base Primary Bucket
resource "aws_s3_bucket" "primary" {
  bucket = local.primary_name
}

#Base Log Bucket
resource "aws_s3_bucket" "log" {
  bucket = local.log_name
}

#AC-3 (Primary) - Public Access blocked on all four vectors
resource "aws_s3_bucket_public_access_block" "primary" {
  bucket = aws_s3_bucket.primary.id


    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

#AC-3 (Log) - Public Access blocked on all four vectors
resource "aws_s3_bucket_public_access_block" "log" {
  bucket = aws_s3_bucket.log.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

#SC-28 (Primary) - encryption at rest (server side encryption)
resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

#SC-28 (Log) - encryption at rest (server side encryption)
resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

#CM-6 (Primary) - versioning on Primary Bucket only
resource "aws_s3_bucket_versioning" "primary" {
  bucket = aws_s3_bucket.primary.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------------------------------------------------------------------
# YOUR BUILD: add the controls. Each is one or more resources you write.
#
#   SC-28  encrypt the primary bucket at rest, and the log bucket too.
#   CM-6   turn on versioning for the primary bucket.
#   AC-3   block public access on both buckets. All four flags must be true.

#   AU-3   let the log bucket receive access logs (ownership controls, then a
#          log-delivery-write ACL), and point the primary bucket's logging at it.
#
# Look up the AWS provider resource names in the Terraform registry. The full
# brief on Patreon explains what each control is and how to verify it.
# ---------------------------------------------------------------------------


# AU-3 / AU-6 (Log) - ownership controls must be set before ACLs can be applied;
# BucketOwnerPreferred keeps the bucket owner in control while still allowing ACLs.
resource "aws_s3_bucket_ownership_controls" "log" {
  bucket = aws_s3_bucket.log.id
  rule {
      object_ownership = "BucketOwnerPreferred"
    }
  }

# AU-3 / AU-6 (Log) - log-delivery-write grants the S3 log delivery group write
# access so the primary bucket can ship its access logs here.
resource "aws_s3_bucket_acl" "log" {
  bucket = aws_s3_bucket.log.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.log,
    aws_s3_bucket_public_access_block.log,
  ]
}

# AU-3 / AU-6 (Primary) - route all access log records to the dedicated log bucket.
resource "aws_s3_bucket_logging" "primary" {
  bucket        = aws_s3_bucket.primary.id
  target_bucket = aws_s3_bucket.log.id
  target_prefix = "s3-access-logs/"
}
