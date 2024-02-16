resource "aws_launch_template" "web_instance_template" {
  name_prefix   = "web-instance-template-"
  image_id      = data.aws_ami.latest.id
  instance_type = "t2.micro"
  # Other instance configurations such as key_name, security_groups, etc.
}

resource "aws_autoscaling_group" "web_asg" {
  launch_template {
    id      = aws_launch_template.web_instance_template.id
    version = "$Latest"
  }

  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  target_group_arns    = [aws_lb_target_group.web_tg.arn] # Assuming you have a target group for your load balancer
  vpc_zone_identifier = [aws_subnet.private_subnet.id] # Assuming private subnet for instances
}

data "aws_ami" "latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["AwsBackup*"]
  }

  filter {
    name   = "creation date"
    values = ["2024/02/01"]
  }

  owners = ["amazon"]
}
