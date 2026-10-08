terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Custom VPC, Subnet & Gateway Setup
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 2. Security Groups
# Backend Security Group (Allows 5000 and 22)
resource "aws_security_group" "backend_sg" {
  name        = "${var.project_name}-backend-sg"
  description = "Allow inbound traffic for Flask API"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask Backend Port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-backend-sg"
  }
}

# Frontend Security Group (Allows 3000 and 22)
resource "aws_security_group" "frontend_sg" {
  name        = "${var.project_name}-frontend-sg"
  description = "Allow inbound traffic for Express Web App"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Express Frontend Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-frontend-sg"
  }
}

# Latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 3. Instance 1: Flask Backend Server
resource "aws_instance" "backend_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e

              sudo apt-get update -y
              sudo apt-get install -y python3 python3-pip

              mkdir -p /home/ubuntu/backend
              cat << 'APP' > /home/ubuntu/backend/app.py
              from flask import Flask, jsonify, request
              from flask_cors import CORS

              app = Flask(__name__)
              CORS(app)

              items = ["Multi-EC2 Setup", "Backend on Separate EC2", "Terraform Managed VPC"]

              @app.route('/api/items', methods=['GET', 'POST'])
              def manage_items():
                  if request.method == 'POST':
                      data = request.get_json() or {}
                      items.append(data.get("item", "New Multi-EC2 Item"))
                      return jsonify({"message": "Item added", "items": items}), 201
                  return jsonify({"items": items, "host": "Flask-EC2-Backend"})

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=5000)
              APP

              pip3 install flask flask-cors
              nohup python3 /home/ubuntu/backend/app.py > /home/ubuntu/flask.log 2>&1 &
              EOF

  tags = {
    Name = "${var.project_name}-backend-instance"
  }
}

# 4. Instance 2: Express Frontend Server (Takes Backend Private IP for communication)
resource "aws_instance" "frontend_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e

              sudo apt-get update -y
              sudo apt-get install -y curl
              curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
              sudo apt-get install -y nodejs

              mkdir -p /home/ubuntu/frontend
              cat << 'SERVER' > /home/ubuntu/frontend/server.js
              const express = require('express');
              const http = require('http');
              const app = express();
              const port = 3000;

              const BACKEND_URL = "http://${aws_instance.backend_server.private_ip}:5000/api/items";

              app.get('/', (req, res) => {
                  res.send(`
                      <!DOCTYPE html>
                      <html>
                      <head><title>Multi-EC2 Architecture</title></head>
                      <body style="font-family: Arial; padding: 40px; text-align: center;">
                          <h2>Deployed via Terraform on Separate EC2 Instances</h2>
                          <p>Frontend Instance IP: <b>${aws_instance.backend_server.private_ip}</b> (Connected to Backend via VPC)</p>
                          <div id="content" style="margin-top: 20px;">Fetching from Flask EC2...</div>
                          <script>
                              fetch('/api/proxy-items')
                                  .then(r => r.json())
                                  .then(data => {
                                      document.getElementById('content').innerHTML = '<b>Items from Flask Backend:</b> ' + data.items.join(', ');
                                  })
                                  .catch(err => {
                                      document.getElementById('content').innerText = 'Backend connection error!';
                                  });
                          </script>
                      </body>
                      </html>
                  `);
              });

              app.get('/api/proxy-items', (req, res) => {
                  http.get(BACKEND_URL, (resp) => {
                      let data = '';
                      resp.on('data', chunk => data += chunk);
                      resp.on('end', () => res.json(JSON.parse(data)));
                  }).on('error', err => res.status(500).json({ error: err.message }));
              });

              app.listen(port, '0.0.0.0', () => console.log('Frontend listening on port ' + port));
              SERVER

              cd /home/ubuntu/frontend
              npm init -y
              npm install express
              nohup node /home/ubuntu/frontend/server.js > /home/ubuntu/express.log 2>&1 &
              EOF

  tags = {
    Name = "${var.project_name}-frontend-instance"
  }
}