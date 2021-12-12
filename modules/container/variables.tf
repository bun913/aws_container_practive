variable "vpc_id" {
  type = string
}

variable "ingress_alb_sg" {
  type = string
}

variable "frontend_subnet1a" {
  type = string
}

variable "frontend_subnet1c" {
  type = string
}

variable "internal_alb_dns_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "green_target" {
  type = string
}

variable "blue_target" {
  type = string
}
