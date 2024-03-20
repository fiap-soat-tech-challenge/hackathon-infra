resource "aws_ecs_task_definition" "point_management" {
  family = "point-management-task"
  container_definitions = jsonencode([
    {
      name      = var.container_name_point_management
      image     = var.container_image_point_management
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name = "point_management"
          containerPort = var.container_port_point_management
          hostPort      = var.container_port_point_management
          protocol = "tcp",
          appProtocol = "http"
        }
      ]
      environment = [
        { "name": "NODE_ENV", "value": "production" },
        { "name": "DB_HOST", "value": "${element(split(":", aws_docdb_cluster.docdb.endpoint), 0)}" },
        { "name": "DB_PORT", "value": "27017" },
        { "name": "DB_USER", "value": "${var.docdb_username}" }, 
        { "name": "DB_PASSWORD", "value": "${var.docdb_password}" },
        { "name": "DB_NAME", "value": "${var.db_name_point_management}" },
        { "name": "DB_SYNCHRONIZE", "value": "true" },
        { "name": "NO_COLOR", "value": "true" },
      ]
      healthCheck = {
        command: ["CMD-SHELL", "curl http://localhost:3000/health || exit 1"],
        startPeriod: 5,
        interval: 10,
        timeout: 5,
        retries: 3,
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.point_management.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn = aws_iam_role.ecsTaskExecutionRole.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_service" "point_management" {
  name                = "point-management-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.point_management.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1
  depends_on = [
    aws_ecs_cluster.this,
    aws_ecs_task_definition.point_management,
    aws_lb.alb
  ]
  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.point_management.arn
    container_name   = var.container_name_point_management
    container_port   = var.container_port_point_management
  }

  network_configuration {
    subnets          = aws_subnet.private_subnet.*.id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  service_connect_configuration {
    enabled = true
    namespace = aws_service_discovery_http_namespace.this.arn
    service {
      port_name      = "point_management"
      discovery_name = "point_management_service"
      client_alias {
        dns_name = "point_management_service"
        port     = 3000
      }
    }
  }
}

resource "aws_appautoscaling_target" "ecs_target_point_management" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.point_management.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_point_management" {
  name               = "autoscaling-point-management"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target_point_management.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target_point_management.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target_point_management.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50
  }
}