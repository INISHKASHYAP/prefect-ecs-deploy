provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "prefect_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "prefect-ecs"
  }
}

resource "aws_internet_gateway" "prefect_igw" {
  vpc_id = aws_vpc.prefect_vpc.id
  tags = {
    Name = "prefect-ecs-igw"
  }
}

resource "aws_subnet" "public" {
  count = 3
  vpc_id                  = aws_vpc.prefect_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.prefect_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "prefect-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = 3
  vpc_id                  = aws_vpc.prefect_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.prefect_vpc.cidr_block, 8, count.index + 3)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "prefect-private-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = 3
  vpc_id                  = aws_vpc.prefect_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.prefect_vpc.cidr_block, 8, count.index + 3)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "prefect-private-${count.index + 1}"
  }
}

resource "aws_eip" "prefect_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "prefect_nat_gateway" {
  allocation_id = aws_eip.prefect_nat_eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "prefect-nat-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.prefect_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prefect_igw.id
  }

  tags = {
    Name = "prefect-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.prefect_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prefect_nat_gateway.id
  }

  tags = {
    Name = "prefect-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

