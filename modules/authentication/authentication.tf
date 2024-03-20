provider "aws" {
  region = var.aws_region
}

##################################
##           Cognito            ##
##################################


# Security Groups 

resource "aws_security_group" "balancers_sg" {
  name_prefix = var.balancers_sg_name
  vpc_id      = var.vpc_id
  description = var.balancers_sg_description

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb_eks" {
  name               = "alb-eks"
  internal           = true
  load_balancer_type = "network"
  security_groups    = [aws_security_group.balancers_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled = true
    path    = "/" # Altere conforme a rota de health check da sua API
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb_eks.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

# resource "aws_api_gateway_vpc_link" "alb_vpc_link" {
#   name        = var.vpc_link_name
#   target_arns = [aws_lb.alb_eks.arn]
# }

resource "aws_apigatewayv2_api" "api_cluster" {
  name          = "api-cluster-tc"
  description   = "API Gateway para acessar a API no EKS"
  protocol_type = "HTTP"
}


resource "aws_apigatewayv2_route" "api_cluster_router" {
  api_id    = aws_apigatewayv2_api.api_cluster.id
  route_key = "$default"
}

resource "aws_apigatewayv2_vpc_link" "api_cluster_vpclink" {
  name               = var.vpc_link_name
  security_group_ids = [aws_security_group.balancers_sg.id]
  subnet_ids         = var.subnet_ids
}

resource "aws_apigatewayv2_integration" "api_cluster_integration" {
  api_id           = aws_apigatewayv2_api.api_cluster.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.alb_listener.arn

  connection_id   = aws_apigatewayv2_vpc_link.api_cluster_vpclink.id
  connection_type = "VPC_LINK"
}


resource "aws_api_gateway_method" "api_method_cluster" {
  rest_api_id   = aws_api_gateway_rest_api.api_cluster.id
  resource_id   = aws_api_gateway_resource.api_resource_cluster.id
  http_method   = "ANY"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "api_integration_cluster" {
  rest_api_id             = aws_api_gateway_rest_api.api_cluster.id
  resource_id             = aws_api_gateway_resource.api_resource_cluster.id
  http_method             = aws_api_gateway_method.api_method_cluster.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = aws_lb_listener.alb_listener.arn
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.alb_vpc_link.id
}


resource "aws_api_gateway_deployment" "api_deployment_cluster" {
  depends_on = [aws_api_gateway_integration.api_integration_cluster]

  rest_api_id = aws_api_gateway_rest_api.api_cluster.id
  stage_name  = "dev"
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.api_deployment_cluster.invoke_url
}

# Target Group

# resource "aws_lb_target_group" "target_group_app" {
#   name     = "target-group-app"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = var.vpc_id
# }


# LoadBalancer

# resource "aws_lb" "load_balancer_app" {
#   name               = var.lb-name
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.balancers_sg.id]
#   subnets            = var.subnet_ids
#   tar
# }


resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name

  password_policy {
    minimum_length    = var.minimum_length_password
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  username_configuration {
    case_sensitive = false
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
  name                         = var.user_pool_client_name
  user_pool_id                 = aws_cognito_user_pool.user_pool.id
  generate_secret              = true
  explicit_auth_flows          = var.explicit_auth_flows
  callback_urls                = [var.callback_urls]
  logout_urls                  = [var.logout_urls]
  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = var.allowed_oauth_flows
  allowed_oauth_scopes = [
    "phone",
    "email",
    "openid",
    "profile",
    "aws.cognito.signin.user.admin"
  ]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = var.user_pool_domain
  user_pool_id = aws_cognito_user_pool.user_pool.id

}


##################################
##          Api Gateway         ##
##################################


# resource "aws_security_group" "eks_cluster_sg" {
#   name_prefix = var.eks_cluster_sg_name
#   description = var.eks_cluster_sg_description
#   vpc_id      = var.vpc_id

#   ingress {
#     description     = "Custom TCP on port 3000"
#     from_port       = 3000
#     to_port         = 3000
#     protocol        = "tcp"
#     security_groups = [aws_security_group.balancers_sg.id]
#   }

#   egress {
#     description = "All traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# resource "aws_lb" "app-lb" {
#   name               = var.lb-name
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.balancers_sg.id]
#   subnets            = var.subnet_ids

#   enable_deletion_protection = true

#   tags = var.tags
# }

# resource "aws_api_gateway_vpc_link" "vpc_link" {
#   name        = var.vpc_link_name
#   description = "Gateway VPC Link. Managed by Terraform."
#   target_arns = [aws_lb.app-lb.arn]
# }


# resource "aws_api_gateway_rest_api" "api_gateway" {
#   name        = var.api_name
#   description = "API protegida via Cognito"
# }


# resource "aws_api_gateway_resource" "check_in_resource" {
#   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
#   parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
#   path_part   = var.resource
#   depends_on  = [aws_api_gateway_rest_api.api_gateway]
# }

# resource "aws_api_gateway_authorizer" "cognito_authorizer" {
#   name            = var.authorizer_name
#   type            = "COGNITO_USER_POOLS"
#   identity_source = "method.request.header.Authorization"
#   rest_api_id     = aws_api_gateway_rest_api.api_gateway.id
#   provider_arns   = [aws_cognito_user_pool.user_pool.arn]

#   depends_on = [
#     aws_api_gateway_rest_api.api_gateway,
#     aws_cognito_user_pool.user_pool
#   ]
# }


# resource "aws_api_gateway_method" "api_gateway_method" {
#   rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
#   resource_id   = aws_api_gateway_resource.check_in_resource.id
#   http_method   = "ANY"
#   authorization = "COGNITO_USER_POOLS"
#   authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

#   request_parameters = {
#     "method.request.path.proxy"           = true
#     "method.request.header.Authorization" = true
#   }

#   depends_on = [
#     aws_api_gateway_rest_api.api_gateway,
#     aws_api_gateway_resource.check_in_resource,
#     aws_api_gateway_authorizer.cognito_authorizer
#   ]
# }

# resource "aws_api_gateway_integration" "api_gateway_integration" {
#   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
#   resource_id = aws_api_gateway_resource.check_in_resource.id
#   http_method = aws_api_gateway_method.api_gateway_method.http_method

#   integration_http_method = "ANY"
#   type                    = "HTTP_PROXY"
#   uri                     = var.url_integration # Substitua pela URL da sua aplicação
#   passthrough_behavior    = "WHEN_NO_MATCH"
#   content_handling        = "CONVERT_TO_TEXT"

#   request_parameters = {
#     "integration.request.path.proxy"           = "method.request.path.proxy"
#     "integration.request.header.Accept"        = "'application/json'"
#     "integration.request.header.Authorization" = "method.request.header.Authorization"
#   }

#   connection_type = "VPC_LINK"

#   depends_on = [
#     aws_api_gateway_method.api_gateway_method,
#     aws_api_gateway_resource.check_in_resource,
#     aws_api_gateway_rest_api.api_gateway
#   ]
# }


# resource "aws_api_gateway_method_response" "check_in_method_response" {
#   for_each    = toset(var.api_status_response)
#   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
#   resource_id = aws_api_gateway_resource.check_in_resource.id
#   http_method = aws_api_gateway_method.api_gateway_method.http_method
#   status_code = each.value
# }

# "myresource"
# "CognitoAuthorizer"
# "http://example.com"
# explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
#   allowed_oauth_flows                  = ["code", "implicit"]
#   allowed_oauth_flows_user_pool_client = true
#   allowed_oauth_scopes                 = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
#   callback_urls                        = ["https://www.example.com/callback"]
#   logout_urls                          = ["https://www.example.com/logout"]
