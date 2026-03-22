variable "environment" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "ami_id" {
  type        = string
  description = "Amazon Linux 2 AMI ID for the region"
  default     = "ami-0c02fb55956c7d316"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "bucket_suffix" {
  type        = string
  description = "Unique suffix for S3 bucket name"
}

variable "alarm_email" {
  type        = string
  description = "Email to receive CloudWatch alarm notifications"
}
