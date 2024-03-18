provider "aws" {
  region = var.aws_region
}

##################################
##           Cognito            ##
##################################

resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name

  password_policy {
    minimum_length    = var.minimum_length_password
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  schema {
    name                = "email"
    required            = true
    attribute_data_type = "String"
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                = var.user_pool_client_name
  user_pool_id        = aws_cognito_user_pool.user_pool.id
  generate_secret     = false
  explicit_auth_flows = var.explicit_auth_flows
  callback_urls       = [var.callback_urls]
  logout_urls         = [var.logout_urls]
}


##################################
##          Api Gateway         ##
##################################



resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.api_name
  description = "API protegida via Cognito"
}


resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name            = var.authorizer_name
  rest_api_id     = aws_api_gateway_rest_api.api_gateway.id
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.user_pool.arn]
  type            = "COGNITO_USER_POOLS"

  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_cognito_user_pool.user_pool
  ]
}

resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = var.resource
  depends_on  = [aws_api_gateway_rest_api.api_gateway]
}

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_resource.api_gateway_resource,
    aws_api_gateway_authorizer.cognito_authorizer
  ]
}

resource "aws_api_gateway_integration" "api_gateway_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.api_gateway_method.http_method
  type        = "AWS_PROXY"
  uri         = var.url_integration # Substitua pela URL da sua aplicação
  depends_on = [
    aws_api_gateway_method.api_gateway_method,
    aws_api_gateway_resource.api_gateway_resource,
    aws_api_gateway_rest_api.api_gateway
  ]
}

# "myresource"
# "CognitoAuthorizer"
# "http://example.com"
# explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
#   allowed_oauth_flows                  = ["code", "implicit"]
#   allowed_oauth_flows_user_pool_client = true
#   allowed_oauth_scopes                 = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
#   callback_urls                        = ["https://www.example.com/callback"]
#   logout_urls                          = ["https://www.example.com/logout"]
