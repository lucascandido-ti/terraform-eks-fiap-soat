variable "aws_region" {}

##################################
##           Cognito            ##
##################################

variable "user_pool_name" {
}

variable "user_pool_client_name" {
}

variable "user_pool_domain" {
}

variable "minimum_length_password" {
}

variable "explicit_auth_flows" {
  type = list(string)
}

variable "allowed_oauth_flows" {
  type = list(string)
}

variable "callback_urls" {
  type = string
}

variable "logout_urls" {
  type = string
}

variable "lb_cookie_name" {
  type = string
}

variable "lb_cookie_timeout" {
  type = string
}


##################################
##          Api Gateway         ##
##################################


variable "api_name" {
  type = string
}

variable "url_integration" {
  type = string
}

variable "resource" {
  type = string
}

variable "authorizer_name" {
  type = string
}

variable "api_status_response" {
  description = "API http status response"
  type        = list(string)
}


variable "lb-name" {

}

variable "security_groups" {

}

variable "subnet_ids" {

}

variable "tags" {

}

variable "vpc_link_name" {

}


variable "vpc_id" {
}
variable "balancers_sg_name" {
}
variable "balancers_sg_description" {
}
variable "eks_cluster_sg_name" {
}
variable "eks_cluster_sg_description" {
}
