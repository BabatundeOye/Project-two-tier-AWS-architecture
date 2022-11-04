#---networking/outputs.tf
output "vpc_id" {
  value = aws_vpc.luit_vpc.id
}