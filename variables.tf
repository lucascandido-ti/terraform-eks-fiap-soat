variable "aws_region" {
  default = "us-east-1"
}

locals {
  cluster_name    = "tech-challenge-cluster"
  node_group_name = "tech-challenge-cluster-worker"
  vpc_name        = "tech-challenge-vpc"
  k8s_name_db     = "tech-challenge-kubernetes-db"
  k8s_name_api    = "tech-challenge-kubernetes-api"

  helm_database = {
    repository = "https://lucascandido-ti.github.io/helm-tech-challenge-soat"
    name       = "database-tech-challenge"
    version    = "0.1.0"
  }

  helm_application = {
    repository = "https://lucascandido-ti.github.io/helm-tech-challenge-soat"
    name       = "application-tech-challenge"
    version    = "0.1.0"
  }

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

variable "terraform" {
  default = "True"
}

##################################
##           Cognito            ##
##################################

variable "user_pool_name" {
  default = "user_pool_tech_challenge"
}

variable "user_pool_client_name" {
  default = "user_pool_client_tech-challenge"
}

variable "minimum_length_password" {
  default = 8
}

variable "explicit_auth_flows" {
  type    = list(string)
  default = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

variable "allowed_oauth_flows" {
  type    = list(string)
  default = ["code", "implicit"]
}

variable "callback_urls" {
  type    = string
  default = "https://www.example.com/callback"
}

variable "logout_urls" {
  type    = string
  default = "https://www.example.com/logout"
}


##################################
##          Api Gateway         ##
##################################


variable "api_name" {
  type    = string
  default = "api_gateway_tech_challenge"
}

variable "url_integration" {
  type    = string
  default = "http://example.com"
}

variable "resource" {
  type    = string
  default = "resource_provider"
}

variable "authorizer_name" {
  type    = string
  default = "CognitoAuthorizer"
}

