// Webserver- Nginx in this example

resource "aws_launch_template" "web_instance_template" {
  name_prefix   = "web-instance-template-"
  image_id      = data.aws_ami.latest.id
  instance_type = "t2.micro"

  block_device_mappings {
    device_name = "/dev/xvda" # Root volume
    ebs {
      volume_size = 10 # Size in GB
    }
  }

  block_device_mappings {
    device_name = "/dev/xvdb" # Secondary volume for logs
    ebs {
      volume_size = 10 # Size in GB
    }
  }

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
    values = ["your-ami-name-pattern*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Provisioning script to install and configure Nginx
resource "aws_instance" "web_instances" {
  count         = var.instance_count
  ami           = data.aws_ami.latest.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = var.key_name
  security_groups = [aws_security_group.instance_security_group.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }

  tags = {
    Name = "WebInstance-${count.index}"
  }
}
