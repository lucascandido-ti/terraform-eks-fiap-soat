variable "aws_region" {}

##################################
##           Cognito            ##
##################################

variable "user_pool_name" {
}

variable "user_pool_client_name" {
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
