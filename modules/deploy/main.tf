// IAM role for deploy
resource "aws_iam_policy" "deploy_plicy" {
  name   = "ecs-deploy-role"
  policy = file("./files/ecs_iam_policy.json")
}

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

resource "aws_codedeploy_app" "app" {
  compute_platform = "ECS"
  name             = "sbcntr-backend"
}

resource "aws_codedeploy_deployment_group" "backend_dg" {
  app_name               = "sbcntr-backend"
  deployment_group_name  = "sbcntr-backend-tg"
  service_role_arn       = aws_iam_role.deploy_role.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = "10"
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${var.blue_lister_arn}"]
      }

      target_group {
        name = var.blue_tg_name
      }

      target_group {
        name = var.greeen_tg_name
      }
    }
  }
}
