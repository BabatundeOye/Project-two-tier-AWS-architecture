#---loadbalancing/main.tf

#Add an application load balancer directing traffic to public subnets
resource "aws_lb" "luit_lb" {
  name               = "luit_loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}