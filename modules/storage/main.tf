# --- S3 Bucket ---
resource "aws_s3_bucket" "main" {
  bucket = "${var.env}-${var.bucket_suffix}-logs-backup"

  tags = {
    Name = "${var.env}-logs-backup"
  }
}

# --- Block All Public Access ---
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Versioning ---
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# --- Server-Side Encryption ---
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- Lifecycle Rules ---
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  # Logs: transition to cheaper storage, then expire
  rule {
    id     = "logs-lifecycle"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  # Backups: transition to Glacier, expire after 2 years
  rule {
    id     = "backups-lifecycle"
    status = "Enabled"

    filter {
      prefix = "backups/"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 730
    }
  }

  # Clean up old non-current versions
  rule {
    id     = "noncurrent-version-cleanup"
    status = "Enabled"

    filter {}

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
