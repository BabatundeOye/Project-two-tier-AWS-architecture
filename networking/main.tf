#---networking/main.tf

data "aws_availability_zones" "available" {}

resource "random_pet" "pet_name" { #assigns pet_name to the vpcname
  length = 2
}

resource "random_shuffle" "az_list" {
    input = data.aws_availability_zones.available.names
    result_count = var.max_subnets
}
resource "aws_vpc" "luit_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "luit_vpc-${random_pet.pet_name.id}"
  }
}

resource "aws_subnet" "luit_public_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.luit_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "luit_public_${count.index + 1}"
  }
}

resource "aws_subnet" "luit_private_subnet" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.luit_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "luit_private_${count.index + 1}"
  }
}