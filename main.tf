data "aws_availability_zones" "available" {}

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

resource "aws_ecs_cluster" "prefect_cluster" {
  name = "prefect-cluster"
}

resource "aws_service_discovery_private_dns_namespace" "prefect_service_discovery" {
  name        = "default.prefect.local"
  vpc         = aws_vpc.prefect_vpc.id
  description = "Prefect service discovery namespace"
}

resource "aws_iam_role" "prefect_task_execution_role" {
  name = "prefect-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.prefect_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_secretsmanager_secret" "prefect_api_key" {
  name        = "PREFECT_API_KEY"
  description = "Prefect API key for Cloud connection"
}

resource "aws_secretsmanager_secret_version" "prefect_api_key_version" {
  secret_id     = aws_secretsmanager_secret.prefect_api_key.id
  secret_string = jsonencode({
    PREFECT_API_KEY = "pnu_Otoj6mnRuv441bPrVwjWRJjkUL3wW445pbuv"
  })
}

resource "aws_ecs_task_definition" "prefect_task" {
  family                   = "prefect-task"
  execution_role_arn       = aws_iam_role.prefect_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name      = "prefect-worker"
    image     = "prefecthq/prefect:2-latest"
    essential = true
    environment = [
      {
        name  = "PREFECT_API_KEY"
        value = aws_secretsmanager_secret_version.prefect_api_key.secret_string
      }
    ]
  }])
}


resource "aws_ecs_service" "prefect_service" {
  name            = "prefect-worker-service"
  cluster         = aws_ecs_cluster.prefect_cluster.id
  task_definition = aws_ecs_task_definition.prefect_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups = [aws_security_group.prefect_sg.id]
    assign_public_ip = false
  }
}

resource "aws_security_group" "prefect_sg" {
  name        = "prefect-worker-sg"
  description = "Security group for Prefect worker"
  vpc_id      = aws_vpc.prefect_vpc.id
}


