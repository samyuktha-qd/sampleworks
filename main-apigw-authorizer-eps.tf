data "aws_region" "current" {}

data "aws_lambda_function" "cp_ui_open_dock_loc_config" {
  function_name = "cp_ui_open_dock_loc_config"
}

data "aws_lambda_function" "cp_ui_auth_handler" {
  function_name = "cp_ui_auth_handler"
}

data "aws_lambda_function" "random-function" {
  function_name = "random-function"
}

resource "aws_api_gateway_rest_api" "customer_portal" {
  name        = "CustomerPortalAPIs"
  description = "Customer Portal APIs"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "portal_authorizer" {
  name            = "portalUIAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.customer_portal.id
  type            = "TOKEN"
  identity_source = "method.request.header.Authorization"
  authorizer_uri  = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_auth_handler.arn}/invocations"
  #identity_validation_expression = "^(Bearer )[a-zA-Z0-9\-_]+?\.[a-zA-Z0-9\-_]+?\.([a-zA-Z0-9\-_]+)$"
  #authorizer_credentials = aws_iam_role.apigateway_execution_role.arn
}


resource "aws_api_gateway_resource" "locations" {
   parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id
   path_part   = "locations"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "locations_config" {
   parent_id   = aws_api_gateway_resource.locations.id
   path_part   = "config"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "locations_config_final" {
   parent_id   = aws_api_gateway_resource.locations_config.id
   path_part   = "final"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "locations_config_final_m_loc_id" {
   parent_id   = aws_api_gateway_resource.locations_config_final.id
   path_part   = "{m_loc_id}"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "locations_config_final_m_loc_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "locations_config_final_m_loc_id_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method   = "POST"
  authorization = "NONE"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "locations_config_final_m_loc_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "locations_config_final_m_loc_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.locations_config_final_m_loc_id_options]
}


resource "aws_api_gateway_integration" "locations_config_final_m_loc_id_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_open_dock_loc_config.arn}/invocations"
}


resource "aws_api_gateway_integration" "locations_config_final_m_loc_id_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_open_dock_loc_config.arn}/invocations"
}


resource "aws_api_gateway_method_response" "locations_config_final_m_loc_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.locations_config_final_m_loc_id_options]
}


resource "aws_api_gateway_method_response" "locations_config_final_m_loc_id_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "locations_config_final_m_loc_id_get_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "locations_config_final_m_loc_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_options.http_method
  status_code = aws_api_gateway_method_response.locations_config_final_m_loc_id_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.locations_config_final_m_loc_id_options_200]
}


 resource "aws_api_gateway_integration_response" "locations_config_final_m_loc_id_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_post.http_method
  status_code = aws_api_gateway_method_response.locations_config_final_m_loc_id_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "locations_config_final_m_loc_id_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_get.http_method
  status_code = aws_api_gateway_method_response.locations_config_final_m_loc_id_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "cp_ui_open_dock_loc_config_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_open_dock_loc_config"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "book" {
   parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id
   path_part   = "book"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "book_book_id" {
   parent_id   = aws_api_gateway_resource.book.id
   path_part   = "{book_id}"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "book_book_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.book_book_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "book_book_id_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.book_book_id.id
  http_method   = "POST"
  authorization = "NONE"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "book_book_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.book_book_id.id
  http_method = aws_api_gateway_method.book_book_id_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.book_book_id_options]
}


resource "aws_api_gateway_integration" "book_book_id_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.book_book_id.id
  http_method = aws_api_gateway_method.book_book_id_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.random-function.arn}/invocations"
}


resource "aws_api_gateway_method_response" "book_book_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.book_book_id.id
  http_method = aws_api_gateway_method.book_book_id_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.book_book_id_options]
}


resource "aws_api_gateway_method_response" "book_book_id_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.book_book_id.id
  http_method = aws_api_gateway_method.book_book_id_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "book_book_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.book_book_id.id
  http_method = aws_api_gateway_method.book_book_id_options.http_method
  status_code = aws_api_gateway_method_response.book_book_id_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.book_book_id_options_200]
}


 resource "aws_api_gateway_integration_response" "book_book_id_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.book_book_id.id
  http_method = aws_api_gateway_method.book_book_id_post.http_method
  status_code = aws_api_gateway_method_response.book_book_id_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "random-function_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "random-function"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}