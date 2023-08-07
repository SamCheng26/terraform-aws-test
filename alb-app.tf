#############################################
## Application Load Balancer Module - Main ##
#############################################

# Create a Security Group for The Load Balancer
resource "aws_security_group" "alb-app-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-alb-app-sg"
  description = "Allow app traffic to the load balancer"
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
    Name        = "${lower(var.app_name)}-${var.app_environment}-alb-app-sg"
    Environment = var.app_environment
  }
}

# Create an Application Load Balancer
resource "aws_lb" "alb-app" {
  name               = "${lower(var.app_name)}-${var.app_environment}-alb-app"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-app-sg.id]
  subnets            = local.ec2_subnet_list

  enable_deletion_protection = false
  enable_http2               = false

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-alb-app"
    Environment = var.app_environment
  }
}

# Create a Load Balancer Target Group for HTTP
resource "aws_lb_target_group" "alb-app-target-group-http" {  
  name     = "${lower(var.app_name)}-${var.app_environment}-app-tg-http"
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


# Create the Application Load Balancer Listener
resource "aws_lb_listener" "alb-app-listener-http" {  
  depends_on = [
    aws_lb.alb-app,
    aws_lb_target_group.alb-app-target-group-http
  ]
  
  load_balancer_arn = aws_lb.alb-app.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = aws_lb_target_group.alb-app-target-group-http.arn
    type             = "forward"  
  }
}


