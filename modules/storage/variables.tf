variable "env" {
  type    = string
  default = "dev"
}

variable "bucket_suffix" {
  type        = string
  description = "Unique suffix to ensure globally unique bucket name"
}
