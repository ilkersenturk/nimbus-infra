resource "aws_ecs_task_definition" "backend_task" {
  family                   = "nimbus-backend-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"       # 0.25 vCPU
  memory                   = "512"       # 512 MB RAM
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "httpbin"
      image     = "kennethreitz/httpbin"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}