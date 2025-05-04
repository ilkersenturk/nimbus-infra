output "public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}
output "web_sg_id" {
  value = aws_security_group.web_sg.id
}