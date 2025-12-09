terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "aviz-tf-bucket"   # <-- replace
    key    = "demo/ec2/terraform.tfstate"
    region = "ap-south-1"                   # <-- replace if needed
  }
}

provider "aws" {
  region = var.aws_region
}
