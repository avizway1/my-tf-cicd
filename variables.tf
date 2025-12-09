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

# reference an existing keypair by name
variable "key_name" {
  type    = string
  default = ""   # set to an existing key pair name if you already have one
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"   # demo only; restrict in production
}

variable "ami_filters" {
  type = map(string)
  default = {
    name                = "amzn2-ami-hvm-*-x86_64-gp2"
    owners              = "amazon"
    most_recent         = "true"
  }
}
