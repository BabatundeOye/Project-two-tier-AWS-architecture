#---root/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.38.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source   = "./networking"
  vpc_cidr = "10.0.0.0/16"
  public_cidrs = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
  private_cidrs = ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"]

}