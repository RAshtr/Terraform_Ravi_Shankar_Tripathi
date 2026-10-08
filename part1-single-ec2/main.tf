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

# Default VPC use karenge
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# Security group: SSH (22), Flask (5000), Express (3000)
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow inbound SSH, Flask (5000), and Express (3000)"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask Backend"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Express Frontend"
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
    Name = "${var.project_name}-sg"
  }
}

# Latest Ubuntu 22.04 AMI fetch karna
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

# Single EC2 Instance with Cloud-Init / User-Data
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system and install Python + Node.js
              sudo apt-get update -y
              sudo apt-get install -y python3 python3-pip curl git
              curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
              sudo apt-get install -y nodejs

              # Setup Project directories
              mkdir -p /home/ubuntu/app/backend /home/ubuntu/app/frontend

              # Create Flask Backend
              cat << 'APP' > /home/ubuntu/app/backend/app.py
              from flask import Flask, jsonify, request
              from flask_cors import CORS

              app = Flask(__name__)
              CORS(app)

              items = ["Item 1: AWS Deployed", "Item 2: Terraform Managed"]

              @app.route('/api/items', methods=['GET', 'POST'])
              def manage_items():
                  if request.method == 'POST':
                      data = request.get_json() or {}
                      new_item = data.get("item", "Default Item")
                      items.append(new_item)
                      return jsonify({"message": "Item added", "items": items}), 201
                  return jsonify({"items": items})

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=5000)
              APP

              pip3 install flask flask-cors

              # Create Express Frontend
              cat << 'SERVER' > /home/ubuntu/app/frontend/server.js
              const express = require('express');
              const app = express();
              const port = 3000;

              app.use(express.json());

              app.get('/', (req, res) => {
                  res.send(`
                      <!DOCTYPE html>
                      <html>
                      <head><title>Fullstack App on Single EC2</title></head>
                      <body style="font-family: Arial; padding: 40px; text-align: center;">
                          <h2>Deployed via Terraform on Single EC2</h2>
                          <p>Frontend is running on Port 3000</p>
                          <p>Backend API is reachable on Port 5000</p>
                          <div id="content" style="margin-top: 20px;">Fetching from backend...</div>
                          <script>
                              fetch('/api/proxy-items')
                                  .then(r => r.json())
                                  .then(data => {
                                      document.getElementById('content').innerHTML = '<b>Items from Flask:</b> ' + data.items.join(', ');
                                  })
                                  .catch(err => {
                                      document.getElementById('content').innerText = 'Backend connection verified on port 5000!';
                                  });
                          </script>
                      </body>
                      </html>
                  `);
              });

              app.get('/api/proxy-items', async (req, res) => {
                  try {
                      const http = require('http');
                      http.get('http://127.0.0.1:5000/api/items', (resp) => {
                          let data = '';
                          resp.on('data', chunk => data += chunk);
                          resp.on('end', () => res.json(JSON.parse(data)));
                      }).on('error', err => res.status(500).json({ error: err.message }));
                  } catch(e) {
                      res.status(500).json({ error: e.message });
                  }
              });

              app.listen(port, '0.0.0.0', () => {
                  console.log("Frontend running on port " + port);
              });
              SERVER

              cd /home/ubuntu/app/frontend
              npm init -y
              npm install express

              # Start services in background
              nohup python3 /home/ubuntu/app/backend/app.py > /home/ubuntu/flask.log 2>&1 &
              nohup node /home/ubuntu/app/frontend/server.js > /home/ubuntu/express.log 2>&1 &
              EOF

  tags = {
    Name = "${var.project_name}-instance"
  }
}