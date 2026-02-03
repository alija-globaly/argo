############### importing resources ##############

##### Note : 
### module name are used as create to avoid conflicts in names in other modules
### But these are imported resources not created resources
module "create_vpc" {
  source = "../modules/import-services/vpc"
  vpc-id = var.vpc-id
}

module "create_subnets" {
  source                    = "../modules/import-services/subnet"
  private_subnet_ids        = var.private_subnet_ids
  public_subnet_ids         = var.public_subnet_ids
  subnet_availability_zones = var.subnet_availability_zones
}

