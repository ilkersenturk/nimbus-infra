variable "vpc_id" {}
variable "alb_listener_arn" {}

# Create the VPC Link to access private ALB from API Gateway
resource "aws_apigatewayv2_vpc_link" "backend_vpc_link" {
  name               = "nimbus-vpc-link"
  subnet_ids = var.private_subnet_ids
  security_group_ids = [] # Optional: allow access to internal ALB

  tags = {
    Name = "nimbus-vpc-link"
  }
}

# HTTP API Gateway
resource "aws_apigatewayv2_api" "backend_api" {
  name          = "nimbus-backend-api"
  protocol_type = "HTTP"

  tags = {
    Name = "nimbus-backend-api"
  }
}

# Integration with internal ALB via VPC Link
resource "aws_apigatewayv2_integration" "backend_integration" {
  api_id             = aws_apigatewayv2_api.backend_api.id
  integration_type   = "HTTP_PROXY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.backend_vpc_link.id
  integration_method = "ANY"
  integration_uri    = var.alb_listener_arn
  payload_format_version = "1.0"
}