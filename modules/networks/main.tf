resource "aws_cloudformation_stack" "network" {
  name          = var.name
  template_body = file(".../../cloudformations/network_step2.yml")
}

data "aws_cloudformation_stack" "network" {
  name = var.name
  depends_on = [
    aws_cloudformation_stack.network
  ]
}

// vpc endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = data.aws_cloudformation_stack.network.outputs["VpcId"]
  service_name      = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    "${data.aws_cloudformation_stack.network.outputs["SubnetEgressA"]}",
    "${data.aws_cloudformation_stack.network.outputs["SubnetEgressC"]}"
  ]
  security_group_ids = [
    "${data.aws_cloudformation_stack.network.outputs["SecurityGroupVpcEndpoint"]}"
  ]
  private_dns_enabled = true
  tags = {
    Name = "sbcntr-vpce-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = data.aws_cloudformation_stack.network.outputs["VpcId"]
  service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    "${data.aws_cloudformation_stack.network.outputs["SubnetEgressA"]}",
    "${data.aws_cloudformation_stack.network.outputs["SubnetEgressC"]}"
  ]
  security_group_ids = [
    "${data.aws_cloudformation_stack.network.outputs["SecurityGroupVpcEndpoint"]}"
  ]
  private_dns_enabled = true
  tags = {
    Name = "sbcntr-vpce-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = data.aws_cloudformation_stack.network.outputs["VpcId"]
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    "${data.aws_cloudformation_stack.network.outputs["RouteAppId"]}",
  ]
  tags = {
    Name = "sbcntr-vpce-s3"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = data.aws_cloudformation_stack.network.outputs["VpcId"]
  service_name      = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    "${data.aws_cloudformation_stack.network.outputs["SubnetEgressA"]}",
    "${data.aws_cloudformation_stack.network.outputs["SubnetEgressC"]}"
  ]
  security_group_ids = [
    "${data.aws_cloudformation_stack.network.outputs["SecurityGroupVpcEndpoint"]}"
  ]
  private_dns_enabled = true
  tags = {
    Name = "sbcntr-vpce-logs"
  }
}

// ALB for Internal
resource "aws_lb" "internal" {
  name               = "sbcntr-alb-internal"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    "${data.aws_cloudformation_stack.network.outputs["SecurityGroupLBInternal"]}"
  ]
  subnets = [
    "${data.aws_cloudformation_stack.network.outputs["SubnetEgressA"]}",
    "${data.aws_cloudformation_stack.network.outputs["SubnetEgressC"]}"
  ]
  enable_deletion_protection = true
}

resource "aws_lb_target_group" "blue_target_group" {
  name     = "sbcntr-tg-sbcntrdemo-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_cloudformation_stack.network.outputs["VpcId"]
  target_type = "ip"
  health_check {
    enabled             = true
    path                = "/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "green_target_group" {
  name     = "sbcntr-tg-sbcntrdemo-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_cloudformation_stack.network.outputs["VpcId"]
  target_type = "ip"
  health_check {
    enabled             = true
    path                = "/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_listener" "blue" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_target_group.arn
  }
}

resource "aws_lb_listener" "green" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "10080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green_target_group.arn
  }
}
