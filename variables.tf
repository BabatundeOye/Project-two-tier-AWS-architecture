#---root/variables.tf
variable "aws_region" {
  description = "my deployment region"
  type        = string
  default     = "us-west-2"
}