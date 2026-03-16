module "network" {
  source = "../../modules/network"
}

module "compute" {
  source = "../../modules/compute"
}

module "storage" {
  source = "../../modules/storage"
}

module "database" {
  source = "../../modules/database"
}

module "security" {
  source = "../../modules/security"
}