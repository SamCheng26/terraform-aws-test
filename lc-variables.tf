variable "ami" {
  description = "AMI Instance ID"
  default = "ami-0a481e6d13af82399" #Amazon Linux 2023
}

variable "instance_type" {
  description = "Type of instance"
  default = "t2.micro"
}

variable "key_name" {
  description = "key name for the instance"
  default = "aws-ofc"
}

data "aws_vpc" "default" {
  default = true
}

/*
data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}
*/