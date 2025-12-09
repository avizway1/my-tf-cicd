variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "name" {
  type    = string
  default = "ec2-demo"
}

# Use existing key pair
variable "key_name" {
  type    = string
  default = "awar06-lnx"
}

# Use existing security group by name
variable "security_group_name" {
  type    = string
  default = "web-sg"
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

