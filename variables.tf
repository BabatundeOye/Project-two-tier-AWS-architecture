#---root/variables.tf
variable "aws_region" {
  description = "my deployment region"
  type        = string
  default     = "us-west-2"
}

variable "access_ip" {
  type = string
}

variable "access_key" {}
variable "secret_key" {}
# variable "key_name" {}