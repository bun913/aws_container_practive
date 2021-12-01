terraform {
  required_version = ">= 1.0.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.67.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}


module "network" {
  source = "./modules/networks"
}

module "container" {
  source = "./modules/container"
}

