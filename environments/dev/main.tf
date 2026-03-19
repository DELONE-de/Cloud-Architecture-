module "vpc" {
  source = "../../modules/vpc"
  env    = var.environment
}

module "security" {
  source = "../../modules/security"
  env    = var.environment
  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source     = "../../modules/IAM"
  env        = var.environment
  account_id = var.account_id
  bucket_arn = module.storage.bucket_arn
}

module "compute" {
  source                = "../../modules/compute"
  env                   = var.environment
  ami_id                = var.ami_id
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.vpc.public_subnet_id
  private_subnet_id     = module.vpc.private_subnet_id
  alb_sg_id             = module.security.alb_sg_id
  app_sg_id             = module.security.app_sg_id
}

module "database" {
  source               = "../../modules/database"
  env                  = var.environment
  private_subnet_id    = module.vpc.private_subnet_id
  private_db_subnet_id = module.vpc.private_db_subnet_id
  db_sg_id             = module.security.db_sg_id
  db_username          = var.db_username
  db_password          = var.db_password
}

module "storage" {
  source        = "../../modules/storage"
  env           = var.environment
  bucket_suffix = var.bucket_suffix
}

module "monitoring" {
  source         = "../../modules/monitoring"
  env            = var.environment
  alarm_email    = var.alarm_email
  asg_name       = module.compute.asg_name
  alb_arn_suffix = module.compute.alb_arn_suffix
  db_identifier  = "${var.environment}-postgres"
}
