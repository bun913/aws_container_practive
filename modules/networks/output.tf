output "vpc_id" {
  value = data.aws_cloudformation_stack.network.outputs["VpcId"]
}

output "ingress_alb_sg_id" {
  value = data.aws_cloudformation_stack.network.outputs["SecurityGroupIngressALB"]
}

output "frontend_subnet1a" {
  value = data.aws_cloudformation_stack.network.outputs["SubnetIgreess1a"]
}

output "frontend_subnet1c" {
  value = data.aws_cloudformation_stack.network.outputs["SubnetIgreess1c"]
}

output "internal_alb_dns_name" {
  value = aws_lb.internal.dns_name
}

output "backend_subnet1a" {
  value = data.aws_cloudformation_stack.network.outputs["SubnetContainer1a"]
}

output "backend_subnet1c" {
  value = data.aws_cloudformation_stack.network.outputs["SubnetContainer1c"]
}

output "container_sg" {
  value = data.aws_cloudformation_stack.network.outputs["SecurityGroupContainer"]
}

output "target_green" {
  value = aws_lb_target_group.green_target_group
}

output "target_blue" {
  value = aws_lb_target_group.blue_target_group
}

output "lister_green" {
  value = aws_lb_listener.green
}

output "lister_blue" {
  value = aws_lb_listener.blue
}
