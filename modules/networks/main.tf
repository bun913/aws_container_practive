resource "aws_cloudformation_stack" "network" {
  name          = var.name
  template_body = file(".../../cloudformations/network_step2.yml")
}

data "aws_cloudformation_stack" "network" {
  name = var.name
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

