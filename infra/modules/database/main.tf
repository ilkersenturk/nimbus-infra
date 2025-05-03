variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "lambda_sg_id" {}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "nimbus-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "nimbus-db-subnet-group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "nimbus-db-sg"
  description = "Allow MySQL access from Lambda only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.lambda_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nimbus-db-sg"
  }
}

resource "aws_db_instance" "mysql" {
  identifier              = "nimbus-mysql-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "admin"
  password                = "NimbusSecure123!" # you can move this to terraform.tfvars
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  multi_az                = false

  tags = {
    Name = "nimbus-mysql-db"
  }
}