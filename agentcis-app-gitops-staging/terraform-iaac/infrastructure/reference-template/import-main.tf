module "import_vpc" {
  source = "../modules/import-services/vpc"
  vpc-id = var.vpc-id
}

module "import_subnet" {
  source                    = "../modules/import-services/subnet"
  private_subnet_ids        = var.private_subnet_ids
  public_subnet_ids         = var.public_subnet_ids
  subnet_availability_zones = var.subnet_availability_zones
}

######### if want to create route-table and vpc gateway only importing subnet id

module "import_subnet_rt_create" {
  source                    = "../modules/import-services/subnet-with_rt-create"
  private_subnet_ids        = var.private_subnet_ids
  public_subnet_ids         = var.public_subnet_ids
  subnet_availability_zones = var.subnet_availability_zones
  internet_gateway_id       = module.create_vpc.igw-id
}