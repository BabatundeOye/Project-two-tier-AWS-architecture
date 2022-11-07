#---networking/outputs.tf
output "vpc_id" {
  value = aws_vpc.luit_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.luit_public_subnet.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.luit_private_subnet.*.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}