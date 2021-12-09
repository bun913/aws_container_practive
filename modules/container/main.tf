// ECR Repository
resource "aws_ecr_repository" "backend" {
  name                 = "sbcntr-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "sbcntr-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
}

// CloudWatchLogs for backend
resource "aws_cloudwatch_log_group" "backend" {
  name              = "sbcntr-backend-log"
  retention_in_days = 30
}

// IAM role for task_definition
resource "aws_iam_policy" "backend_task_df_policy" {
  name   = "sbcntr-backend-td-policy"
  policy = file("./files/task_df_policy.json")
}

resource "aws_iam_role" "backend_task_df_role" {
  name = "ecsTaskExecutionRoleForFargate"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.backend_task_df_policy.arn]
}

// ECS
resource "aws_ecs_task_definition" "service" {
  family                   = "sbcntr-backend-def"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.backend_task_df_role.arn
  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "ap-northeast-1"
          awslogs-group         = aws_cloudwatch_log_group.backend.id
          awslogs-stream-prefix = "backend-app"
        }
      }
    }
  ])
}

resource "aws_ecs_cluster" "backend" {
  name = "sbcntr-ecs-backend-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "backend" {
  name                               = "sbcntr-ecs-backend-service"
  cluster                            = aws_ecs_cluster.backend.id
  task_definition                    = aws_ecs_task_definition.service.id
  launch_type                        = "FARGATE"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  // iam_role                = aws_iam_service_linked_role.ecs.id */
  enable_ecs_managed_tags = true

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.blue_target
    container_name   = "app"
    container_port   = 80
  }
}

