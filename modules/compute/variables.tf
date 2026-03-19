variable "env" {
  type    = string
  default = "dev"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances (e.g. Amazon Linux 2)"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet for the ALB"
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet for the ASG instances"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for the ALB"
}

variable "app_sg_id" {
  type        = string
  description = "Security group ID for the app servers"
}
