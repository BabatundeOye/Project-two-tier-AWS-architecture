#---networking/main.tf

data "aws_availability_zones" "available" {} #data source for available AZs

resource "random_pet" "pet_name" { #assigns pet_name to the vpcname
  length = 2
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}
resource "aws_vpc" "luit_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "luit_vpc-${random_pet.pet_name.id}"
  }
  lifecycle {
    create_before_destroy = true
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

resource "aws_internet_gateway" "luit_internet_gateway" {
  vpc_id = aws_vpc.luit_vpc.id

  tags = {
    Name = "luit_igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "luit_eip" {
  vpc = true

  tags = {
    Name = "luit_eip"
  }
}

resource "aws_nat_gateway" "luit_nat_gateway" {
  allocation_id = aws_eip.luit_eip.id
  subnet_id     = aws_subnet.luit_public_subnet[0].id

  tags = {
    Name = "luit_nat_gateway"
  }
}

#public route table
resource "aws_route_table" "luit_public_rt" {
  vpc_id = aws_vpc.luit_vpc.id

  tags = {
    Name = "luit_public"
  }
}

#private route table
resource "aws_route_table" "luit_private_rt" {
  vpc_id = aws_vpc.luit_vpc.id

  tags = {
    Name = "luit_private"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.luit_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.luit_nat_gateway.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.luit_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.luit_internet_gateway.id
}

resource "aws_route_table_association" "luit_private_association" {
  count          = var.private_sn_count
  subnet_id      = aws_subnet.luit_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.luit_private_rt.id
}

resource "aws_route_table_association" "luit_public_association" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.luit_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.luit_public_rt.id
}
#security group for bastion host
resource "aws_security_group" "bastion_sg" { 
  name        = "bastion_sg"
  description = "allow SSH access"
  vpc_id      = aws_vpc.luit_vpc.id

  ingress {
    description = "allow inbound traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion_sg"
  }
}

# ALB SG
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP inbound traffic for web servers"
  vpc_id      = aws_vpc.luit_vpc.id

  ingress {
    description = "Allow HTTP inbound traffic for web servers"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

#security-group for the web-server
resource "aws_security_group" "webserver_sg" {
  name        = "webserver_sg"
  description = "Allow HTTP inbound traffic from lb and SSH traffic from bastion host"
  vpc_id      = aws_vpc.luit_vpc.id


  ingress {
    description     = "Allow SSH traffic from Bastion Host security group"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "Allow HTTP traffic from ALB security group"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver_sg"
  }
}

