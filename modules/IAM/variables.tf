variable "env" {
  type    = string
  default = "dev"
}

variable "account_id" {
  type        = string
  description = "AWS account ID for Terraform deployment role trust policy"
}

variable "bucket_arn" {
  type        = string
  description = "ARN of the S3 logs-backup bucket for EC2 scoped access"
}
