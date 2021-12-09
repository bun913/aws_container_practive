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
