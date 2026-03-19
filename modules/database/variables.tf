variable "env" {
  type    = string
  default = "dev"
}

variable "private_subnet_id" {
  type        = string
  description = "Private app subnet ID"
}

variable "private_db_subnet_id" {
  type        = string
  description = "Private DB subnet ID"
}

variable "db_sg_id" {
  type        = string
  description = "Database security group ID"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}
