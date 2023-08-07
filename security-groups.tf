resource "aws_security_group" "websg" {
  vpc_id      =  aws_vpc.vpc.id 
  name        = "allow_http"
  description = "Allow http inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "rds-sg" {

  vpc_id            =  aws_vpc.vpc.id   
  name_prefix       =  "Allow 3306"
  description       =  "allows 3306"


  ingress {
    
    from_port        = 3306 
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["10.11.0.0/16"]
  }

  egress {
    
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}