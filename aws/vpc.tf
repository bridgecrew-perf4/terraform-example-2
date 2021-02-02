resource "aws_vpc" "vpc" {
  assign_generated_ipv6_cidr_block = "false"
  cidr_block                       = var.vpc_cidr
  enable_classiclink               = "false"
  enable_classiclink_dns_support   = "false"
  enable_dns_hostnames             = "false"
  enable_dns_support               = "true"
  instance_tenancy                 = "default"

  tags = {
    Name = "${var.name}-vpc"
  }
}

###
# Private Subnets
###

resource "aws_subnet" "sn1a" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = format("%s%s", substr(var.vpc_cidr, 0, 6), "1.0/24")
  map_public_ip_on_launch         = "false"
  availability_zone               = "eu-west-1a"

  tags = {
    Name = "${var.name}-sn-1a"
  }

  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "sn1b" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = format("%s%s", substr(var.vpc_cidr, 0, 6), "2.0/24")
  map_public_ip_on_launch         = "false"
  availability_zone               = "eu-west-1b"

  tags = {
    Name = "${var.name}-sn-1b"
  }

  vpc_id = aws_vpc.vpc.id
}

###
# Public Subnet
###

resource "aws_subnet" "sn1a_pub" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = format("%s%s", substr(var.vpc_cidr, 0, 6), "4.0/24")
  map_public_ip_on_launch         = "false"
  availability_zone               = "eu-west-1a"

  tags = {
    Name = "${var.name}-sn1a-pub"
  }

  vpc_id = aws_vpc.vpc.id
}
resource "aws_subnet" "sn1b_pub" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = format("%s%s", substr(var.vpc_cidr, 0, 6), "5.0/24")
  map_public_ip_on_launch         = "false"
  availability_zone               = "eu-west-1b"

  tags = {
    Name = "${var.name}-sn1b-pub"
  }

  vpc_id = aws_vpc.vpc.id
}

###
# Route Tables
###

resource "aws_route_table" "rt_pub" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }

  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "${var.name}-private-rt"
  }

  vpc_id = aws_vpc.vpc.id
}

###
# Route Table Associations
###

resource "aws_route_table_association" "sn1a_assoc" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.sn1a.id
}

resource "aws_route_table_association" "sn1b_assoc" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.sn1b.id
}

resource "aws_route_table_association" "sn1a_pub_assoc" {
  route_table_id = aws_route_table.rt_pub.id
  subnet_id      = aws_subnet.sn1a_pub.id
}

resource "aws_route_table_association" "sn1b_pub_assoc" {
  route_table_id = aws_route_table.rt_pub.id
  subnet_id      = aws_subnet.sn1b_pub.id
}

###
# Internet Gateway
###

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "${var.name}-igw"
  }

  vpc_id = aws_vpc.vpc.id
}

###
# NAT Gateway
###

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.sn1a_pub.id

  tags = {
    Name = "${var.name}-nat-gtw"
  }
}

###
# Elastic IPs
###

resource "aws_eip" "eip_nat" {
  network_border_group = "eu-west-1"
  public_ipv4_pool     = "amazon"
  vpc                  = true
}