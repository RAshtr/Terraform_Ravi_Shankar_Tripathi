output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP of the deployed EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "flask_url" {
  description = "URL to access Flask Backend"
  value       = "http://${aws_instance.app_server.public_ip}:5000/api/items"
}

output "express_url" {
  description = "URL to access Express Frontend"
  value       = "http://${aws_instance.app_server.public_ip}:3000"
}