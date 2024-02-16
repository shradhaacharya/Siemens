resource "aws_acm_certificate" "self_signed_cert" {
  domain_name       = "test.example.com"
  validation_method = "DNS"
}

resource "aws_lb_listener_certificate" "lb_cert" {
  listener_arn    = aws_lb_listener.lb_listener.arn
  certificate_arn = aws_acm_certificate.self_signed_cert.arn
}

resource "aws_route53_zone" "private_zone" {
  name                      = "test.example.com"
  vpc_id                    = aws_vpc.my_vpc.id
  private_zone              = true
}

resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.self_signed_cert.arn
}

# Create an A record in the private hosted zone to resolve test.example.com to the load balancer
resource "aws_route53_record" "lb_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "test.example.com"
  type    = "A"
  ttl     = "300"
  records = [aws_lb.web_lb.dns_name]
}

# Update VPC DHCP options to use Route 53 Resolver
resource "aws_vpc_dhcp_options" "resolver_options" {
  domain_name          = "test.example.com"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "resolver_association" {
  vpc_id          = aws_vpc.my_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.resolver_options.id
}
