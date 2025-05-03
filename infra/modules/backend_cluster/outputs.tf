output "backend_alb_dns" {
  description = "Internal ALB DNS name for the ECS backend"
  value       = aws_lb.backend_alb.dns_name
}


output "backend_service_name" {
  description = "ECS backend service name"
  value       = aws_ecs_service.backend_service.name
}

output "backend_target_group_arn" {
  description = "Target group ARN for ECS backend"
  value       = aws_lb_target_group.backend_tg.arn
}


