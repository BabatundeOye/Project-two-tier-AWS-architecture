#loadbalancing/main.tf

#application load balancer directing traffic to public subnets
resource "aws_lb" "luit_lb" {
  name               = "luit-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "luit_lb"
  }
}

#Target group
resource "aws_lb_target_group" "luit_tg" {
  name     = "luit-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

#ALB listener 
resource "aws_lb_listener" "luit_listener" {
  load_balancer_arn = aws_lb.luit_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.luit_tg.arn
  }
}