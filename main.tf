#---root/main.tf

module "networking" {
  source           = "./networking"
  vpc_cidr         = "10.0.0.0/16"
  public_sn_count  = 3
  private_sn_count = 3
  max_subnets = 10
  public_cidrs     = [for i in range(1, 255, 2) : cidrsubnet("10.0.0.0/16", 8, i)]
  private_cidrs    = [for i in range(2, 255, 2) : cidrsubnet("10.0.0.0/16", 8, i)]

}