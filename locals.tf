locals {
  ec2_subnet_list = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
}