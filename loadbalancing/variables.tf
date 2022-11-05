#---loadbalancing/variables.tf

variable "public_subnet_ids" {}


variable "alb_sg_id" {
  type = string
}

variable "vpc_id" {
  type = string
}