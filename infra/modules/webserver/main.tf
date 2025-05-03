# Amazon Machine Image
variable "ami_id" {
  default = "ami-0c02fb55956c7d316" # Amazon Linux 2 in us-east-2
}

# Declares what type of EC2 instance to launch (CPU/RAM).
variable "instance_type" {
  default = "t2.micro"
}

# They define where to launch the EC2 (what subnet/VPC).
variable "subnet_id" {}
variable "vpc_id" {}
variable "key_name" {
  default = null
}

# Security Group for Web Server
# Defines the inbound and outbound traffic rules (firewall) for your EC2 instance.

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id

# Allows everyone to access your instance on port 80 (web server)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Lets you SSH in (if a key is attached)
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Allows all outbound traffic (so instance can reach the internet, download packages, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# EC2 Web Server Instance
# Creates the actual virtual machine (EC2) that runs your website or app.

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

# ✅ ADD THIS BLOCK
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Welcome to Nimbus Web Server (Nginx)</h1>" > /usr/share/nginx/html/index.html
  EOF
  

  tags = {
    Name = "nimbus-web"
  }
}