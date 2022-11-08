#---loadbalancing/output.tf

output "asg_tg_arn" {
  value = aws_lb_target_group.luit_tg.arn
}