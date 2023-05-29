terraform {
  required_version = ">= 1.1.4, < 1.5.0"

    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 4.67"
      }
    }
}
provider "aws"{
  region = "eu-central-1"
}

data "aws_vpc" "default" {
  default = true
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}