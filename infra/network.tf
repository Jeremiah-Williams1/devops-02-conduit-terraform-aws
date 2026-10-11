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

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "conduit-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "conduit-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = toset(["public-a", "public-b"])

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "conduit-private-app-rt"
  }
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "conduit-private-db-rt"
  }
}

resource "aws_route_table_association" "private_app" {
  for_each = toset(["app-a", "app-b"])

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "private_db" {
  for_each = toset(["db-a", "db-b"])

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.private_db.id
}