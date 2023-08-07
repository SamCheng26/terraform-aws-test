#############################################
## Application Load Balancer Module - Main ##
#############################################

# Create a Security Group for The Load Balancer
resource "aws_security_group" "alb-web-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-alb-web-sg"
  description = "Allow web traffic to the load balancer"
  vpc_id      = aws_vpc.vpc.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-alb-web-sg"
    Environment = var.app_environment
  }
}

# Create an Application Load Balancer
resource "aws_lb" "alb-web" {
  name               = "${lower(var.app_name)}-${var.app_environment}-alb-web"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-web-sg.id]
  subnets            = local.ec2_subnet_list

  enable_deletion_protection = false
  enable_http2               = false

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-alb-web"
    Environment = var.app_environment
  }
}

# Create a Load Balancer Target Group for HTTP
resource "aws_lb_target_group" "alb-web-target-group-http" {  
  name     = "${lower(var.app_name)}-${var.app_environment}-web-tg-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  
  deregistration_delay = 60

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200,301,302"
  }
}

/*
# Attach EC2 Instances to Application Load Balancer Target Group
resource "aws_alb_target_group_attachment" "alb-web-target-group-http-attach" {
  count = var.ec2_count

  target_group_arn = aws_lb_target_group.alb-web-target-group-http.arn
  target_id        = aws_instance.asg-server[count.index].id
  port             = 80
}
*/

# Create the Application Load Balancer Listener
resource "aws_lb_listener" "alb-web-listener-http" {  
  depends_on = [
    aws_lb.alb-web,
    aws_lb_target_group.alb-web-target-group-http
  ]
  
  load_balancer_arn = aws_lb.alb-web.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = aws_lb_target_group.alb-web-target-group-http.arn
    type             = "forward"  
  }
}

# ######################################

# Reference to the AWS Route53 Public Zone
data "aws_route53_zone" "public-zone" {
  name         = var.public_dns_name
  private_zone = false
}

# Create AWS Route53 A Record for the Load Balancer
resource "aws_route53_record" "alb-web-a-record" {
  depends_on = [aws_lb.alb-web]

  zone_id = data.aws_route53_zone.public-zone.zone_id
  name    = "${var.dns_hostname}.${var.public_dns_name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb-web.dns_name
    zone_id                = aws_lb.alb-web.zone_id
    evaluate_target_health = true
  }
}

# ######################################

# Create Certificate
resource "aws_acm_certificate" "alb-web-certificate" {
  domain_name       = "${var.dns_hostname}.${var.public_dns_name}"
  validation_method = "DNS"
  
  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-alb-web-certificate"
    Environment = var.app_environment
  }
}

# Create AWS Route 53 Certificate Validation Record
resource "aws_route53_record" "alb-web-certificate-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.alb-web-certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.public-zone.zone_id
}

# Create Certificate Validation
resource "aws_acm_certificate_validation" "asg-certificate-validation" {
  certificate_arn         = aws_acm_certificate.alb-web-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.alb-web-certificate-validation-record : record.fqdn]
}

# ######################################

# Create Application Load Balancer Listener for HTTPS
resource "aws_alb_listener" "alb-web-listener-https" {
  depends_on = [
    aws_acm_certificate.alb-web-certificate,
    aws_route53_record.alb-web-certificate-validation-record,
    aws_acm_certificate_validation.asg-certificate-validation
  ]

  load_balancer_arn = aws_lb.alb-web.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.alb-web-certificate.arn

  default_action {
    target_group_arn = aws_lb_target_group.alb-web-target-group-http.arn
    type = "forward"
  }
}