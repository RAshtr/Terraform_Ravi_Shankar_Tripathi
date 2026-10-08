output "vpc_id" {
  description = "Custom VPC ID"
  value       = aws_vpc.custom_vpc.id
}

output "backend_public_ip" {
  description = "Public IP of Flask Backend EC2"
  value       = aws_instance.backend_server.public_ip
}

output "frontend_public_ip" {
  description = "Public IP of Express Frontend EC2"
  value       = aws_instance.frontend_server.public_ip
}

output "flask_api_url" {
  description = "Direct URL to Flask API"
  value       = "http://${aws_instance.backend_server.public_ip}:5000/api/items"
}

output "express_web_url" {
  description = "URL to Express Frontend"
  value       = "http://${aws_instance.frontend_server.public_ip}:3000"
}