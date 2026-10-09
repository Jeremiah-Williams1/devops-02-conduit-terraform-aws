resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "conduit-vpc"
  }
}

locals {
  subnets = {
    public-a = { cidr = "10.0.1.0/24",  az = "us-east-1a" }
    public-b = { cidr = "10.0.2.0/24",  az = "us-east-1b" }
    app-a    = { cidr = "10.0.11.0/24", az = "us-east-1a" }
    app-b    = { cidr = "10.0.12.0/24", az = "us-east-1b" }
    db-a     = { cidr = "10.0.21.0/24", az = "us-east-1a" }
    db-b     = { cidr = "10.0.22.0/24", az = "us-east-1b" }
  }
}

resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "conduit-${each.key}"
  }
}