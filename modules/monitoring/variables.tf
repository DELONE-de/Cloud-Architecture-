variable "env" {
  type    = string
  default = "dev"
}

variable "alarm_email" {
  type        = string
  description = "Email address to receive alarm notifications"
}

variable "asg_name" {
  type        = string
  description = "Auto Scaling Group name for EC2 CPU alarm"
}

variable "alb_arn_suffix" {
  type        = string
  description = "ALB ARN suffix for 5xx alarm (from aws_lb.app.arn_suffix)"
}

variable "db_identifier" {
  type        = string
  description = "RDS DB instance identifier for storage alarm"
}
