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

// IAM role for deploy
resource "aws_iam_role" "deploy_role" {
  name = "ecsCodeDeployRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.deploy_plicy.arn]
}

resource "aws_iam_policy" "deploy_plicy" {
  name   = "ecs-deploy-role"
  policy = file("./files/ecs_iam_policy.json")
}

// CloudWatchLogs for backend
resource "aws_cloudwatch_log_group" "backend" {
  name              = "sbcntr-backend-log"
  retention_in_days = 30
}

// ECS
resource "aws_ecs_task_definition" "service" {
  family                   = "sbcntr-backend-def"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
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
          awslogs-region = "ap-northeast-1"
          awslogs-group  = aws_cloudwatch_log_group.backend.id
        }
      }
    }
  ])
}

