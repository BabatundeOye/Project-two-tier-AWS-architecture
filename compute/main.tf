#---compute/main.tf

data "aws_ami" "linux_server" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "random_id" "my_id" {
  byte_length = 8
}

resource "aws_launch_template" "bastion_template" {
  name                   = "bastion_template"
  image_id               = data.aws_ami.linux_server.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.bastion_sg_id]

  tags = {
    Name = "bastion_template-${random_id.my_id.id}"

  }
}

resource "aws_autoscaling_group" "bastion_host_asg" {
  vpc_zone_identifier = var.public_subnet_ids
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.bastion_template.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "webserver_template" {
  name                   = "webserver_template"
  image_id               = data.aws_ami.linux_server.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.web_server_sg_id]

  tags = {
    Name = "webserver_template-${random_id.my_id.id}"

  }
}

resource "aws_autoscaling_group" "webserver_asg" {
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.webserver_template.id
    version = "$Latest"
  }
}


# Create ASG Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.webserver_asg.id
  lb_target_group_arn    = var.asg_tg_arn
}