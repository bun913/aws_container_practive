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
