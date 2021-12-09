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
