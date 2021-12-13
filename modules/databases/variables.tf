variable "subnet_db1" {
  type = string
}

variable "subnet_db2" {
  type = string
}

variable "db_pass" {
  type      = string
  sensitive = true
}

variable "db_sg" {
  type = string
}

