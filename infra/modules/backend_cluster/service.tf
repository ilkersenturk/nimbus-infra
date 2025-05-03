resource "aws_ecs_service" "backend_service" {
  name            = "nimbus-backend-service"
  cluster         = aws_ecs_cluster.backend.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 2

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.backend_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "httpbin"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.backend_listener
  ]
}