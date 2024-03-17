variable "aws_region" {
  default = "us-east-1"
}

locals {
  cluster_name = "tech-challenge-cluster"
  vpc_name     = "tech-challenge-vpc"
  common_tags = {
    terraform = var.terraform
  }
}

variable "ami_type" {
  default = "AL2_x86_64"
}

variable "instance_type_nodes" {
  default = "t3.micro"
}

variable "desired_nodes" {
  type    = number
  default = 3
}

#tags
variable "terraform" {
  default = "True"
}
