# Crear VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Red privada network #1
resource "aws_subnet" "private-network-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_network_cidr_1
  availability_zone = var.aws_us_east_2c
}

# Red privada network #2
resource "aws_subnet" "private-network-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_network_cidr_2
  availability_zone = var.aws_us_east_2d
}

# Red publica network #1
resource "aws_subnet" "public-network-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_network_cidr_1
  availability_zone = var.aws_us_east_2c
}

# Red publica network #2
resource "aws_subnet" "public-network-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_network_cidr_2
  availability_zone = var.aws_us_east_2d
}

# Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

# IP Publica NAT Gateway
resource "aws_eip" "nat-gateway" {
  vpc = true
}

# Crea NAT Gateway
resource "aws_nat_gateway" "nat" {
  depends_on    = [aws_internet_gateway.internet_gateway]
  allocation_id = aws_eip.nat-gateway.id
  subnet_id     = aws_subnet.public-network-1.id
}

# Route table private
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}

# 
resource "aws_route_table_association" "private-route-table-network-1-association" {
  subnet_id      = aws_subnet.private-network-1.id
  route_table_id = aws_route_table.private-route-table.id
}

# 
resource "aws_route_table_association" "private-route-table-network-2-association" {
  subnet_id      = aws_subnet.private-network-2.id
  route_table_id = aws_route_table.private-route-table.id
}

# 
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

# 
resource "aws_route_table_association" "public-route-table-network-1-association" {
  subnet_id      = aws_subnet.public-network-1.id
  route_table_id = aws_route_table.public-route-table.id
}

# 
resource "aws_route_table_association" "public-route-table-network-2-association" {
  subnet_id      = aws_subnet.public-network-2.id
  route_table_id = aws_route_table.public-route-table.id
}