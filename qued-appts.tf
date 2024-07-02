data "aws_region" "current" {}

data "aws_lambda_function" "cp_ui_auth_handler" {
  function_name = "cp_ui_auth_handler"
}

data "aws_lambda_function" "new_appt" {
  function_name = "new_appt"
}

data "aws_lambda_function" "update_resc_appt" {
  function_name = "update_resc_appt"
}

data "aws_lambda_function" "update_ship_details" {
  function_name = "update_ship_details"
}

data "aws_lambda_function" "update_stop_details" {
  function_name = "update_stop_details"
}

data "aws_lambda_function" "cancel_appt" {
  function_name = "cancel_appt"
}

data "aws_lambda_function" "qued_appt_api_auth" {
  function_name = "qued_appt_api_auth"
}


resource "aws_api_gateway_rest_api" "customer_portal" {
  name        = "CustomerPortalAPIs"
  description = "Customer Portal APIs"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "portal_authorizer" {
  name            = "qued_appt_api_auth"
  rest_api_id     = aws_api_gateway_rest_api.customer_portal.id
  type            = "TOKEN"
  identity_source = "method.request.header.Authorization"
  authorizer_uri  = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_auth_handler.arn}/invocations"
  #identity_validation_expression = "^(Bearer )[a-zA-Z0-9\-_]+?\.[a-zA-Z0-9\-_]+?\.([a-zA-Z0-9\-_]+)$"
  #authorizer_credentials = aws_iam_role.apigateway_execution_role.arn
}


resource "aws_api_gateway_resource" "appointments" {
   parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id
   path_part   = "appointments"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "appointments_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointments.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "appointments_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointments.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "appointments_put" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointments.id
  http_method   = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "appointments_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments.id
  http_method = aws_api_gateway_method.appointments_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.appointments_options]
}


resource "aws_api_gateway_integration" "appointments_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments.id
  http_method = aws_api_gateway_method.appointments_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.new_appt.arn}/invocations"
}


resource "aws_api_gateway_integration" "appointments_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments.id
  http_method = aws_api_gateway_method.appointments_put.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.update_resc_appt.arn}/invocations"
}


resource "aws_api_gateway_method_response" "appointments_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments.id
  http_method = aws_api_gateway_method.appointments_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.appointments_options]
}


resource "aws_api_gateway_method_response" "appointments_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments.id
  http_method = aws_api_gateway_method.appointments_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "appointments_put_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments.id
  http_method = aws_api_gateway_method.appointments_put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "appointments_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments.id
  http_method = aws_api_gateway_method.appointments_options.http_method
  status_code = aws_api_gateway_method_response.appointments_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.appointments_options_200]
}


resource "aws_api_gateway_integration_response" "appointments_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments.id
  http_method = aws_api_gateway_method.appointments_post.http_method
  status_code = aws_api_gateway_method_response.appointments_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_api_gateway_integration_response" "appointments_put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments.id
  http_method = aws_api_gateway_method.appointments_put.http_method
  status_code = aws_api_gateway_method_response.appointments_put_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "new_appt_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "new_appt"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}


resource "aws_lambda_permission" "update_resc_appt_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "update_resc_appt"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "appointments_wk" {
   parent_id   = aws_api_gateway_resource.appointments.id
   path_part   = "wk"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "appointments_wk_shipments" {
   parent_id   = aws_api_gateway_resource.appointments_wk.id
   path_part   = "shipments"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "appointments_wk_shipments_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointments_wk_shipments.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "appointments_wk_shipments_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointments_wk_shipments.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "appointments_wk_shipments_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_shipments.id
  http_method = aws_api_gateway_method.appointments_wk_shipments_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.appointments_wk_shipments_options]
}


resource "aws_api_gateway_integration" "appointments_wk_shipments_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_shipments.id
  http_method = aws_api_gateway_method.appointments_wk_shipments_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.update_ship_details.arn}/invocations"
}


resource "aws_api_gateway_method_response" "appointments_wk_shipments_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_shipments.id
  http_method = aws_api_gateway_method.appointments_wk_shipments_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.appointments_wk_shipments_options]
}


resource "aws_api_gateway_method_response" "appointments_wk_shipments_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_shipments.id
  http_method = aws_api_gateway_method.appointments_wk_shipments_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "appointments_wk_shipments_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_shipments.id
  http_method = aws_api_gateway_method.appointments_wk_shipments_options.http_method
  status_code = aws_api_gateway_method_response.appointments_wk_shipments_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.appointments_wk_shipments_options_200]
}


resource "aws_api_gateway_integration_response" "appointments_wk_shipments_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_shipments.id
  http_method = aws_api_gateway_method.appointments_wk_shipments_post.http_method
  status_code = aws_api_gateway_method_response.appointments_wk_shipments_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "update_ship_details_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "update_ship_details"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "appointments_wk_stops" {
   parent_id   = aws_api_gateway_resource.appointments_wk.id
   path_part   = "stops"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "appointments_wk_stops_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointments_wk_stops.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "appointments_wk_stops_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointments_wk_stops.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "appointments_wk_stops_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_stops.id
  http_method = aws_api_gateway_method.appointments_wk_stops_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.appointments_wk_stops_options]
}


resource "aws_api_gateway_integration" "appointments_wk_stops_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_stops.id
  http_method = aws_api_gateway_method.appointments_wk_stops_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.update_stop_details.arn}/invocations"
}


resource "aws_api_gateway_method_response" "appointments_wk_stops_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_stops.id
  http_method = aws_api_gateway_method.appointments_wk_stops_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.appointments_wk_stops_options]
}


resource "aws_api_gateway_method_response" "appointments_wk_stops_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_stops.id
  http_method = aws_api_gateway_method.appointments_wk_stops_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "appointments_wk_stops_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_stops.id
  http_method = aws_api_gateway_method.appointments_wk_stops_options.http_method
  status_code = aws_api_gateway_method_response.appointments_wk_stops_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.appointments_wk_stops_options_200]
}


 resource "aws_api_gateway_integration_response" "appointments_wk_stops_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_wk_stops.id
  http_method = aws_api_gateway_method.appointments_wk_stops_post.http_method
  status_code = aws_api_gateway_method_response.appointments_wk_stops_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "update_stop_details_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "update_stop_details"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "appointments_cancel" {
   parent_id   = aws_api_gateway_resource.appointments.id
   path_part   = "cancel"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "appointments_cancel_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointments_cancel.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "appointments_cancel_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointments_cancel.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "appointments_cancel_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_cancel.id
  http_method = aws_api_gateway_method.appointments_cancel_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.appointments_cancel_options]
}


resource "aws_api_gateway_integration" "appointments_cancel_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_cancel.id
  http_method = aws_api_gateway_method.appointments_cancel_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cancel_appt.arn}/invocations"
}


resource "aws_api_gateway_method_response" "appointments_cancel_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_cancel.id
  http_method = aws_api_gateway_method.appointments_cancel_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.appointments_cancel_options]
}


resource "aws_api_gateway_method_response" "appointments_cancel_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_cancel.id
  http_method = aws_api_gateway_method.appointments_cancel_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "appointments_cancel_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_cancel.id
  http_method = aws_api_gateway_method.appointments_cancel_options.http_method
  status_code = aws_api_gateway_method_response.appointments_cancel_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.appointments_cancel_options_200]
}


resource "aws_api_gateway_integration_response" "appointments_cancel_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointments_cancel.id
  http_method = aws_api_gateway_method.appointments_cancel_post.http_method
  status_code = aws_api_gateway_method_response.appointments_cancel_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "cancel_appt_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cancel_appt"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}
