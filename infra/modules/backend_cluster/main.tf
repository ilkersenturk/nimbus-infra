variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "web_sg_id" {}

# ECS Cluster
resource "aws_ecs_cluster" "backend" {
  name = "nimbus-backend-cluster"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Security Group for backend tasks (only allow from webserver SG)
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Allow traffic only from web server"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow HTTP from webserver"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [var.web_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}

# Internal Application Load Balancer
resource "aws_lb" "backend_alb" {
  name               = "nimbus-backend-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.private_subnet_ids
  security_groups    = [aws_security_group.backend_sg.id]

  tags = {
    Name = "nimbus-backend-alb"
  }
}