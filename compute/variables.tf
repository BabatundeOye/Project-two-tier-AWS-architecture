#---compute/varaibles.tf

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type      = string
  sensitive = true
}

variable "bastion_sg_id" {}

variable "public_subnet_ids" {}

variable "vpc_id" {}