
# Creating variable vpc_id by default
variable "vpc_id" {}

# creating variable list private_subnet_dis
variable "private_subnet_ids" {
  type = list(string)
}

# generating rand resource name random_id
resource "random_id" "rand" {
  byte_length = 4
}

# S3 Bucket (private)
# Creating a s3 bucker , and having option to delete by force 
resource "aws_s3_bucket" "upload_bucket" {
  bucket        = "nimbus-upload-bucket-${random_id.rand.hex}"
  force_destroy = true

  tags = {
    Name = "nimbus-private-upload"
  }
}

# IAM Role for Lambda
# allowing lambda service to use IAM
resource "aws_iam_role" "lambda_exec_role" {
  name = "nimbus_lambda_exec_role-${random_id.rand.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for S3 access and logging
resource "aws_iam_role_policy" "lambda_policy" {
  name = "nimbus_lambda_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.upload_bucket.arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}

# Lambda security group for VPC access
resource "aws_security_group" "backend_lambda_sg" {
  name        = "lambda-sg"
  description = "Allow Lambda to connect to RDS"
  vpc_id      = var.vpc_id

  # allowing outbound internet traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-sg"
  }
}

# Lambda function (inline Python)
resource "aws_lambda_function" "s3_trigger" {
  function_name = "s3_trigger_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"

  filename         = "lambda/index.zip"
  source_code_hash = filebase64sha256("lambda/index.zip")

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.backend_lambda_sg.id]
  }
}

# Allow S3 to invoke Lambda on object upload
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

# Hook S3 to trigger Lambda
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_trigger.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}