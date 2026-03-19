# backend "s3" disabled for local planning without AWS credentials
# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state-bucket"
#     key            = "dev/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-lock-table"
#   }
# }