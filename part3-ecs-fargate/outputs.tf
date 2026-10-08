output "backend_ecr_url" {
  description = "ECR Repository URL for Backend"
  value       = aws_ecr_repository.backend_repo.repository_url
}

output "frontend_ecr_url" {
  description = "ECR Repository URL for Frontend"
  value       = aws_ecr_repository.frontend_repo.repository_url
}

output "alb_dns_name" {
  description = "Public Application Load Balancer DNS"
  value       = aws_lb.main.dns_name
}

output "frontend_url" {
  description = "Frontend application URL via ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

output "backend_url" {
  description = "Backend API URL via ALB"
  value       = "http://${aws_lb.main.dns_name}:5000/api/items"
}