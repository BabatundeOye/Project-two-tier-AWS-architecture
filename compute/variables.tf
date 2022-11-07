#---compute/variables.tf

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type = string

}

variable "bastion_sg_id" {}

variable "public_subnet_ids" {}

variable "vpc_id" {}

variable "web_server_sg_id" {}

variable "private_subnet_ids" {}