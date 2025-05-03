output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "web_server_public_ip" {
  description = "Public IP of the Nginx web server (EC2)"
  value       = module.webserver.public_ip
}

output "backend_alb_dns" {
  description = "DNS name of the ECS backend Application Load Balancer"
  value       = module.backend_cluster.backend_alb_dns
}

output "api_gateway_url" {
  description = "URL of the API Gateway that routes to backend ALB"
  value       = module.api_gateway.api_gateway_url
}

output "upload_bucket_name" {
  description = "The S3 bucket that triggers the Lambda function"
  value       = module.s3_and_lambda.upload_bucket_name
}

output "rds_endpoint" {
  description = "MySQL RDS endpoint address"
  value       = module.database.db_endpoint
}

output "rds_port" {
  description = "MySQL RDS port"
  value       = module.database.db_port
}