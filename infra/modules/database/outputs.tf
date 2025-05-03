output "db_endpoint" {
  description = "The endpoint of the RDS MySQL instance"
  value       = aws_db_instance.mysql.endpoint
}

output "db_port" {
  description = "The port used by the RDS MySQL instance"
  value       = aws_db_instance.mysql.port
}