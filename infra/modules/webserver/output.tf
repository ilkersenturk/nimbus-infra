output "public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}
