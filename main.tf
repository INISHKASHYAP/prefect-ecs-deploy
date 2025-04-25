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

