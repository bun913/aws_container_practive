output "ecr_backend" {
  value = aws_ecr_repository.backend
}

output "ecr_frontend" {
  value = aws_ecr_repository.frontend
}

output "cluster_name" {
  value = aws_ecs_cluster.backend.name
}

output "service_name" {
  value = aws_ecs_service.backend.name
}

