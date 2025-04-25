output "vpc_id" {
  value = aws_vpc.prefect_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}
output "ecs_cluster_arn" {
  value = aws_ecs_cluster.prefect_cluster.arn
}


