resource "aws_cloudformation_stack" "network" {
  name = "sbcntr-base"
  template_body = file(".../../cloudformations/network_step1.yml")
}
