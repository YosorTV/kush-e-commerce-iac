output "ecr_repo_backend_arn" {
  value = aws_ecr_repository.backend.arn
}

output "ecr_repo_backend_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}
output "ecr_repo_frontend_arn" {
  value = aws_ecr_repository.frontend.arn
}

output "ecr_repo_frontend_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}