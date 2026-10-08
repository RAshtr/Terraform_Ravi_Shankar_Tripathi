variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Project prefix for multi-instance deployment"
  type        = string
  default     = "multi-ec2"
}