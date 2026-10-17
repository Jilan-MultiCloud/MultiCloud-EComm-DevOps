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
  region = "ap-south-1"
}

# --- VPC Infrastructure Setup ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "MultiCloud-EComm-VPC" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "MultiCloud-EComm-IGW" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags                    = { Name = "MultiCloud-EComm-PublicSubnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "MultiCloud-EComm-PublicRT" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Cloud Security Groups Framework ---
resource "aws_security_group" "app_sg" {
  name        = "MultiCloud-EComm-SG"
  description = "Allows ingress public web layer traffic and localized service communications"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3001
    to_port     = 3004
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "MultiCloud-EComm-SecurityGroup" }
}

# --- Targeted Compute Engine Node ---
resource "aws_instance" "web_app" {
  ami                    = "ami-03f4878755434977f" # Canonical Ubuntu 22.04 LTS AMI for ap-south-1
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = "new_ec2_key"

  # 🎯 Bypasses external Docker repositories by pulling directly from official Ubuntu repositories
  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              
              echo "=== Installing Native Docker Engine ==="
              apt-get update -y
              apt-get install -y docker.io
              
              systemctl enable docker
              systemctl start docker
              
              echo "=== Pulling Containers from jbshk Registry ==="
              DOCKER_USER="jbshk"
              docker pull \$DOCKER_USER/frontend-service:latest
              docker pull \$DOCKER_USER/user-service:latest
              docker pull \$DOCKER_USER/product-service:latest
              docker pull \$DOCKER_USER/order-service:latest
              docker pull \$DOCKER_USER/cart-service:latest
              
              echo "=== Launching Container Mesh Stack ==="
              docker run -d --name frontend -p 80:80 --restart unless-stopped \$DOCKER_USER/frontend-service:latest
              docker run -d --name user-srv -p 3001:3001 --restart unless-stopped \$DOCKER_USER/user-service:latest
              docker run -d --name product-srv -p 3002:3002 --restart unless-stopped \$DOCKER_USER/product-service:latest
              docker run -d --name order-srv -p 3003:3003 --restart unless-stopped \$DOCKER_USER/order-service:latest
              docker run -d --name cart-srv -p 3004:3004 --restart unless-stopped \$DOCKER_USER/cart-service:latest
              EOF

  tags = { Name = "MultiCloud-EComm-AppServer" }
}

# --- Deployment Metrics Output Registration ---
output "application_public_ip" {
  value       = aws_instance.web_app.public_ip
  description = "The target public IP block mapping address to reach your Frontend web client container."
}

output "application_url" {
  value       = "http://${aws_instance.web_app.public_ip}"
  description = "Evaluator browser connection target location string entry parameters."
}
