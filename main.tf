# Resolve default VPC
data "aws_vpc" "default" {
  default = true
}

# Resolve default subnets in the default VPC
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  subnet_id = length(data.aws_subnets.default_subnets.ids) > 0 ? data.aws_subnets.default_subnets.ids[0] : null
}

# Look up existing security group by name (in the same region/account)
data "aws_security_group" "existing" {
  filter {
    name   = "group-name"
    values = [var.security_group_name]
  }
}

# Find the latest Amazon Linux 2023 AMI (owner = amazon)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2023-ami-*-x86_64*"]
  }
}

resource "aws_instance" "demo" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id
  vpc_security_group_ids = [data.aws_security_group.existing.id]

  key_name = var.key_name

  tags = {
    Name = var.name
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              EOF
}
