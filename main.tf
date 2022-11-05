#---root/main.tf



module "networking" {
  source           = "./networking"
  vpc_cidr         = local.vpc_cidr
  access_ip        = "10.0.0.0/16"
  public_sn_count  = 3
  private_sn_count = 3
  max_subnets      = 10
  public_cidrs     = [for i in range(1, 255, 2) : cidrsubnet("10.0.0.0/16", 8, i)]
  private_cidrs    = [for i in range(2, 255, 2) : cidrsubnet("10.0.0.0/16", 8, i)]

}
module "loadbalancing" {
  source            = "./loadbalancing"
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.networking.alb_sg_id
  vpc_id            = module.networking.vpc_id


}