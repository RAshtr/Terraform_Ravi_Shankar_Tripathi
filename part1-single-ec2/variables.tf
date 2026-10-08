variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Project resource tag prefix"
  type        = string
  default     = "single-ec2-deployment"
}