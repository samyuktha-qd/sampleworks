
data "aws_region" "current" {}

data "aws_lambda_function" "cp_ui_auth_handler" {
  function_name = "cp_ui_auth_handler"
}

data "aws_lambda_function" "cp_ui_get_stops" {
  function_name = "cp_ui_get_stops"
}

data "aws_lambda_function" "cp_ui_get_stop_timeline" {
  function_name = "cp_ui_get_stop_timeline"
}

data "aws_lambda_function" "cp_ui_get_timeline_content" {
  function_name = "cp_ui_get_timeline_content"
}

data "aws_lambda_function" "cp_ui_appointment_handler" {
  function_name = "cp_ui_appointment_handler"
}

data "aws_lambda_function" "cp_ui_accept_appt" {
  function_name = "cp_ui_accept_appt"
}

data "aws_lambda_function" "cp_ui_grp_stops" {
  function_name = "cp_ui_grp_stops"
}

data "aws_lambda_function" "cp_ui_get_locations" {
  function_name = "cp_ui_get_locations"
}
data "aws_lambda_function" "cp_ui_create_location" {
  function_name = "cp_ui_create_location"
}
data "aws_lambda_function" "cp_ui_delete_location" {
  function_name = "cp_ui_delete_location"
}
data "aws_lambda_function" "cp_ui_update_location" {
  function_name = "cp_ui_update_location"
}
data "aws_lambda_function" "cp_ui_get_stop_detail" {
  function_name = "cp_ui_get_stop_detail"
}

data "aws_lambda_function" "cp_ui_cognito_users" {
  function_name = "cp_ui_cognito_users"
}

data "aws_lambda_function" "cp_ui_notification" {
  function_name = "cp_ui_notification"
}

data "aws_lambda_function" "appt_emailrsp_manual_review" {
  function_name = "appt_emailrsp_manual_review"
}

data "aws_lambda_function" "cp_ui_tenant_customisation" {
  function_name = "cp_ui_tenant_customisation"
}

data "aws_lambda_function" "cp_ui_open_dock_loc_config" {
  function_name = "cp_ui_open_dock_loc_config"
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

resource "aws_api_gateway_resource" "appointment" {
  parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id
  path_part   = "appointment"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "appointment_confirm" {
  parent_id   = aws_api_gateway_resource.appointment.id
  path_part   = "confirm"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "appointment_accept" {
  parent_id   = aws_api_gateway_resource.appointment.id
  path_part   = "accept"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "appointment_accept_stop_id" {
  parent_id   = aws_api_gateway_resource.appointment_accept.id
  path_part   = "{stopid}"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "stop" {
  parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id
  path_part   = "stop"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "related_orders" {
  parent_id   = aws_api_gateway_resource.stop.id
  path_part   = "related-order"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "related_orders_group_id" {
  parent_id   = aws_api_gateway_resource.related_orders.id
  path_part   = "{groupid}"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "timeline" {
  parent_id   = aws_api_gateway_resource.stop.id
  path_part   = "timeline"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "stop_timeline_stop_id" {
  parent_id   = aws_api_gateway_resource.timeline.id
  path_part   = "{stopid}"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "tl_content_type" {
  parent_id   = aws_api_gateway_resource.stop_timeline_stop_id.id
  path_part   = "{content_type}"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_resource" "tl_content_type_id" {
  parent_id   = aws_api_gateway_resource.tl_content_type.id
  path_part   = "{id}"
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "confirm_appointment_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointment_confirm.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "appointment_accept_stop_id_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointment_accept_stop_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "stop_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.stop.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "related_orders_group_id_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.related_orders_group_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "stop_timeline_stop_id_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.stop_timeline_stop_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "tl_content_type_id_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.tl_content_type_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "conf_appt_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_confirm.id
  http_method = aws_api_gateway_method.confirm_appointment_options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.confirm_appointment_options_method]
}

resource "aws_api_gateway_integration" "appointment_accept_stop_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_accept_stop_id.id
  http_method = aws_api_gateway_method.appointment_accept_stop_id_options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.appointment_accept_stop_id_options_method]
}

resource "aws_api_gateway_integration" "stop_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop.id
  http_method = aws_api_gateway_method.stop_options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.stop_options_method]
}

resource "aws_api_gateway_integration" "related_orders_group_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.related_orders_group_id.id
  http_method = aws_api_gateway_method.related_orders_group_id_options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.related_orders_group_id_options_method]
}

resource "aws_api_gateway_integration" "stop_timeline_stop_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_timeline_stop_id.id
  http_method = aws_api_gateway_method.stop_timeline_stop_id_options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.stop_timeline_stop_id_options_method]
}

resource "aws_api_gateway_integration" "tl_content_type_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tl_content_type_id.id
  http_method = aws_api_gateway_method.tl_content_type_id_options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.tl_content_type_id_options_method]
}

resource "aws_api_gateway_method_response" "conf_appt_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_confirm.id
  http_method = aws_api_gateway_method.confirm_appointment_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.confirm_appointment_options_method]
}

resource "aws_api_gateway_method_response" "appointment_accept_stop_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_accept_stop_id.id
  http_method = aws_api_gateway_method.appointment_accept_stop_id_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.appointment_accept_stop_id_options_method]
}

resource "aws_api_gateway_method_response" "stop_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop.id
  http_method = aws_api_gateway_method.stop_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.stop_options_method]
}

resource "aws_api_gateway_method_response" "related_orders_group_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.related_orders_group_id.id
  http_method = aws_api_gateway_method.related_orders_group_id_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.related_orders_group_id_options_method]
}

resource "aws_api_gateway_method_response" "stop_timeline_stop_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_timeline_stop_id.id
  http_method = aws_api_gateway_method.stop_timeline_stop_id_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.stop_timeline_stop_id_options_method]
}

resource "aws_api_gateway_method_response" "tl_content_type_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tl_content_type_id.id
  http_method = aws_api_gateway_method.tl_content_type_id_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.tl_content_type_id_options_method]
}

resource "aws_api_gateway_integration_response" "conf_appt_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_confirm.id
  http_method = aws_api_gateway_method.confirm_appointment_options_method.http_method
  status_code = aws_api_gateway_method_response.conf_appt_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.conf_appt_options_200]
}

resource "aws_api_gateway_integration_response" "appointment_accept_stop_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_accept_stop_id.id
  http_method = aws_api_gateway_method.appointment_accept_stop_id_options_method.http_method
  status_code = aws_api_gateway_method_response.appointment_accept_stop_id_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.appointment_accept_stop_id_options_200]
}

resource "aws_api_gateway_integration_response" "stop_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop.id
  http_method = aws_api_gateway_method.stop_options_method.http_method
  status_code = aws_api_gateway_method_response.stop_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.stop_options_200]
}

resource "aws_api_gateway_integration_response" "related_orders_group_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.related_orders_group_id.id
  http_method = aws_api_gateway_method.related_orders_group_id_options_method.http_method
  status_code = aws_api_gateway_method_response.related_orders_group_id_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.related_orders_group_id_options_200]
}

resource "aws_api_gateway_integration_response" "stop_timeline_stop_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_timeline_stop_id.id
  http_method = aws_api_gateway_method.stop_timeline_stop_id_options_method.http_method
  status_code = aws_api_gateway_method_response.stop_timeline_stop_id_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.stop_timeline_stop_id_options_200]
}

resource "aws_api_gateway_integration_response" "tl_content_type_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tl_content_type_id.id
  http_method = aws_api_gateway_method.tl_content_type_id_options_method.http_method
  status_code = aws_api_gateway_method_response.tl_content_type_id_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.tl_content_type_id_options_200]
}

resource "aws_api_gateway_method" "confirm_appointment" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointment_confirm.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}

resource "aws_api_gateway_method" "appointment_accept_stop_id" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointment_accept_stop_id.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}

resource "aws_api_gateway_method" "stop" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.stop.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}

resource "aws_api_gateway_method" "stop_timeline_stop_id" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.stop_timeline_stop_id.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}

resource "aws_api_gateway_method" "related_orders_group_id" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.related_orders_group_id.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}

resource "aws_api_gateway_method" "tl_content_type_id" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.tl_content_type_id.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}

resource "aws_api_gateway_integration" "confirm_appointment_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_confirm.id
  http_method = aws_api_gateway_method.confirm_appointment.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_appointment_handler.arn}/invocations"
}

resource "aws_api_gateway_integration" "appointment_accept_stop_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_accept_stop_id.id
  http_method = aws_api_gateway_method.appointment_accept_stop_id.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_accept_appt.arn}/invocations"
}

resource "aws_api_gateway_integration" "stop_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop.id
  http_method = aws_api_gateway_method.stop.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_get_stops.arn}/invocations"
}

resource "aws_api_gateway_integration" "related_orders_group_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.related_orders_group_id.id
  http_method = aws_api_gateway_method.related_orders_group_id.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_grp_stops.arn}/invocations"
}

resource "aws_api_gateway_integration" "stop_timeline_stop_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_timeline_stop_id.id
  http_method = aws_api_gateway_method.stop_timeline_stop_id.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_get_stop_timeline.arn}/invocations"
}

resource "aws_api_gateway_integration" "tl_content_type_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tl_content_type_id.id
  http_method = aws_api_gateway_method.tl_content_type_id.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_get_timeline_content.arn}/invocations"
}

resource "aws_api_gateway_method_response" "confirm_appointment_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_confirm.id
  http_method = aws_api_gateway_method.confirm_appointment.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_method_response" "appointment_accept_stop_id_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_accept_stop_id.id
  http_method = aws_api_gateway_method.appointment_accept_stop_id.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_method_response" "stop_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop.id
  http_method = aws_api_gateway_method.stop.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_method_response" "related_orders_group_id_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.related_orders_group_id.id
  http_method = aws_api_gateway_method.related_orders_group_id.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_method_response" "stop_timeline_stop_id_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_timeline_stop_id.id
  http_method = aws_api_gateway_method.stop_timeline_stop_id.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_method_response" "tl_content_type_id_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tl_content_type_id.id
  http_method = aws_api_gateway_method.tl_content_type_id.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "confirm_appointment_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_confirm.id
  http_method = aws_api_gateway_method.confirm_appointment.http_method
  status_code = aws_api_gateway_method_response.confirm_appointment_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "appointment_accept_stop_id_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_accept_stop_id.id
  http_method = aws_api_gateway_method.appointment_accept_stop_id.http_method
  status_code = aws_api_gateway_method_response.appointment_accept_stop_id_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "stop_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop.id
  http_method = aws_api_gateway_method.stop.http_method
  status_code = aws_api_gateway_method_response.stop_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "related_orders_group_id_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.related_orders_group_id.id
  http_method = aws_api_gateway_method.related_orders_group_id.http_method
  status_code = aws_api_gateway_method_response.related_orders_group_id_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "stop_timeline_stop_id_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_timeline_stop_id.id
  http_method = aws_api_gateway_method.stop_timeline_stop_id.http_method
  status_code = aws_api_gateway_method_response.stop_timeline_stop_id_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "tl_content_type_id_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tl_content_type_id.id
  http_method = aws_api_gateway_method.tl_content_type_id.http_method
  status_code = aws_api_gateway_method_response.tl_content_type_id_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}



resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration_response.confirm_appointment_integration_response,
    aws_api_gateway_integration_response.stop_integration_response,
  aws_api_gateway_integration_response.stop_timeline_stop_id_integration_response, aws_api_gateway_integration_response.tl_content_type_id_integration_response]
}


resource "aws_lambda_permission" "cp_ui_auth_handler_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_auth_handler"
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_lambda_permission" "cp_ui_get_stops_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_get_stops"
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_lambda_permission" "related_orders_group_id_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_grp_stops"
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_lambda_permission" "cp_ui_get_stop_timeline_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_get_stop_timeline"
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_lambda_permission" "cp_ui_get_timeline_content_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_get_timeline_content"
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_lambda_permission" "cp_ui_appointment_handler_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_appointment_handler"
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_lambda_permission" "cp_ui_accept_appt_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_accept_appt"
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "locations" {
   parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id
   path_part   = "locations"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "locations_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    
resource "aws_api_gateway_method" "locations_get" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "locations_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "locations_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.locations_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.locations_options]
}


resource "aws_api_gateway_integration" "locations_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.locations_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_get_locations.arn}/invocations"
}


resource "aws_api_gateway_integration" "locations_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.locations_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_create_location.arn}/invocations"
}


resource "aws_api_gateway_method_response" "locations_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.locations_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.locations_options]
}


resource "aws_api_gateway_method_response" "locations_get_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.locations_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "locations_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.locations_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "locations_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.locations_options.http_method
  status_code = aws_api_gateway_method_response.locations_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.locations_options_200]
}


 resource "aws_api_gateway_integration_response" "locations_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.locations_get.http_method
  status_code = aws_api_gateway_method_response.locations_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "locations_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.locations_post.http_method
  status_code = aws_api_gateway_method_response.locations_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "cp_ui_get_locations_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_get_locations"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}


resource "aws_lambda_permission" "cp_ui_create_location_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_create_location"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "locations_t_loc_id" {
   parent_id   = aws_api_gateway_resource.locations.id
   path_part   = "{t_loc_id}"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "locations_t_loc_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_t_loc_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "locations_t_loc_id_delete" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_t_loc_id.id
  http_method   = "DELETE"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "locations_t_loc_id_put" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_t_loc_id.id
  http_method   = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "locations_t_loc_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_t_loc_id.id
  http_method = aws_api_gateway_method.locations_t_loc_id_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.locations_t_loc_id_options]
}


resource "aws_api_gateway_integration" "locations_t_loc_id_delete_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_t_loc_id.id
  http_method = aws_api_gateway_method.locations_t_loc_id_delete.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_delete_location.arn}/invocations"
}


resource "aws_api_gateway_integration" "locations_t_loc_id_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_t_loc_id.id
  http_method = aws_api_gateway_method.locations_t_loc_id_put.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_update_location.arn}/invocations"
}


resource "aws_api_gateway_method_response" "locations_t_loc_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_t_loc_id.id
  http_method = aws_api_gateway_method.locations_t_loc_id_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.locations_t_loc_id_options]
}


resource "aws_api_gateway_method_response" "locations_t_loc_id_delete_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_t_loc_id.id
  http_method = aws_api_gateway_method.locations_t_loc_id_delete.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "locations_t_loc_id_put_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_t_loc_id.id
  http_method = aws_api_gateway_method.locations_t_loc_id_put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "locations_t_loc_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_t_loc_id.id
  http_method = aws_api_gateway_method.locations_t_loc_id_options.http_method
  status_code = aws_api_gateway_method_response.locations_t_loc_id_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.locations_t_loc_id_options_200]
}


 resource "aws_api_gateway_integration_response" "locations_t_loc_id_delete_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_t_loc_id.id
  http_method = aws_api_gateway_method.locations_t_loc_id_delete.http_method
  status_code = aws_api_gateway_method_response.locations_t_loc_id_delete_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "locations_t_loc_id_put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_t_loc_id.id
  http_method = aws_api_gateway_method.locations_t_loc_id_put.http_method
  status_code = aws_api_gateway_method_response.locations_t_loc_id_put_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "cp_ui_delete_location_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_delete_location"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}


resource "aws_lambda_permission" "cp_ui_update_location_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_update_location"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "stop_stop_id" {
   parent_id   = aws_api_gateway_resource.stop.id
   path_part   = "{stop_id}"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "stop_stop_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.stop_stop_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "stop_stop_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.stop_stop_id.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "stop_stop_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_stop_id.id
  http_method = aws_api_gateway_method.stop_stop_id_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.stop_stop_id_options]
}


resource "aws_api_gateway_integration" "stop_stop_id_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_stop_id.id
  http_method = aws_api_gateway_method.stop_stop_id_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_get_stop_detail.arn}/invocations"
}


resource "aws_api_gateway_method_response" "stop_stop_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_stop_id.id
  http_method = aws_api_gateway_method.stop_stop_id_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.stop_stop_id_options]
}


resource "aws_api_gateway_method_response" "stop_stop_id_get_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_stop_id.id
  http_method = aws_api_gateway_method.stop_stop_id_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "stop_stop_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_stop_id.id
  http_method = aws_api_gateway_method.stop_stop_id_options.http_method
  status_code = aws_api_gateway_method_response.stop_stop_id_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.stop_stop_id_options_200]
}


 resource "aws_api_gateway_integration_response" "stop_stop_id_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.stop_stop_id.id
  http_method = aws_api_gateway_method.stop_stop_id_get.http_method
  status_code = aws_api_gateway_method_response.stop_stop_id_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "cp_ui_get_stop_detail_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_get_stop_detail"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "users" {
   parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id
   path_part   = "users"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "users_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "users_get" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "users_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "users_delete" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "DELETE"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "users_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.users_options]
}


resource "aws_api_gateway_integration" "users_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_cognito_users.arn}/invocations"
}


resource "aws_api_gateway_integration" "users_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_cognito_users.arn}/invocations"
}


resource "aws_api_gateway_integration" "users_delete_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_delete.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_cognito_users.arn}/invocations"
}


resource "aws_api_gateway_method_response" "users_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.users_options]
}


resource "aws_api_gateway_method_response" "users_get_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "users_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "users_delete_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_delete.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "users_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_options.http_method
  status_code = aws_api_gateway_method_response.users_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.users_options_200]
}


 resource "aws_api_gateway_integration_response" "users_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_get.http_method
  status_code = aws_api_gateway_method_response.users_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "users_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_post.http_method
  status_code = aws_api_gateway_method_response.users_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "users_delete_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_delete.http_method
  status_code = aws_api_gateway_method_response.users_delete_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "cp_ui_cognito_users_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_cognito_users"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}


resource "aws_api_gateway_resource" "users_enable" {
   parent_id   = aws_api_gateway_resource.users.id
   path_part   = "enable"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "users_enable_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users_enable.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "users_enable_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users_enable.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "users_enable_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_enable.id
  http_method = aws_api_gateway_method.users_enable_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.users_enable_options]
}


resource "aws_api_gateway_integration" "users_enable_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_enable.id
  http_method = aws_api_gateway_method.users_enable_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_cognito_users.arn}/invocations"
}


resource "aws_api_gateway_method_response" "users_enable_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_enable.id
  http_method = aws_api_gateway_method.users_enable_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.users_enable_options]
}


resource "aws_api_gateway_method_response" "users_enable_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_enable.id
  http_method = aws_api_gateway_method.users_enable_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "users_enable_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_enable.id
  http_method = aws_api_gateway_method.users_enable_options.http_method
  status_code = aws_api_gateway_method_response.users_enable_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.users_enable_options_200]
}


 resource "aws_api_gateway_integration_response" "users_enable_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_enable.id
  http_method = aws_api_gateway_method.users_enable_post.http_method
  status_code = aws_api_gateway_method_response.users_enable_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_api_gateway_resource" "users_disable" {
   parent_id   = aws_api_gateway_resource.users.id
   path_part   = "disable"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "users_disable_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users_disable.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "users_disable_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users_disable.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "users_disable_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_disable.id
  http_method = aws_api_gateway_method.users_disable_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.users_disable_options]
}


resource "aws_api_gateway_integration" "users_disable_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_disable.id
  http_method = aws_api_gateway_method.users_disable_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_cognito_users.arn}/invocations"
}


resource "aws_api_gateway_method_response" "users_disable_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_disable.id
  http_method = aws_api_gateway_method.users_disable_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.users_disable_options]
}


resource "aws_api_gateway_method_response" "users_disable_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_disable.id
  http_method = aws_api_gateway_method.users_disable_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "users_disable_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_disable.id
  http_method = aws_api_gateway_method.users_disable_options.http_method
  status_code = aws_api_gateway_method_response.users_disable_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.users_disable_options_200]
}


 resource "aws_api_gateway_integration_response" "users_disable_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_disable.id
  http_method = aws_api_gateway_method.users_disable_post.http_method
  status_code = aws_api_gateway_method_response.users_disable_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_api_gateway_resource" "users_resend" {
   parent_id   = aws_api_gateway_resource.users.id
   path_part   = "resend"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "users_resend_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users_resend.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "users_resend_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.users_resend.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "users_resend_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_resend.id
  http_method = aws_api_gateway_method.users_resend_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.users_resend_options]
}


resource "aws_api_gateway_integration" "users_resend_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_resend.id
  http_method = aws_api_gateway_method.users_resend_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_cognito_users.arn}/invocations"
}


resource "aws_api_gateway_method_response" "users_resend_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_resend.id
  http_method = aws_api_gateway_method.users_resend_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.users_resend_options]
}


resource "aws_api_gateway_method_response" "users_resend_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_resend.id
  http_method = aws_api_gateway_method.users_resend_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "users_resend_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_resend.id
  http_method = aws_api_gateway_method.users_resend_options.http_method
  status_code = aws_api_gateway_method_response.users_resend_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.users_resend_options_200]
}


 resource "aws_api_gateway_integration_response" "users_resend_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.users_resend.id
  http_method = aws_api_gateway_method.users_resend_post.http_method
  status_code = aws_api_gateway_method_response.users_resend_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_api_gateway_resource" "notification" {
   parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id
   path_part   = "notification"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "notification_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.notification.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "notification_get" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.notification.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "notification_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.notification.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "notification_put" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.notification.id
  http_method   = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "notification_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.notification_options]
}


resource "aws_api_gateway_integration" "notification_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_notification.arn}/invocations"
}


resource "aws_api_gateway_integration" "notification_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_notification.arn}/invocations"
}


resource "aws_api_gateway_integration" "notification_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_put.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_notification.arn}/invocations"
}


resource "aws_api_gateway_method_response" "notification_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.notification_options]
}


resource "aws_api_gateway_method_response" "notification_get_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_method_response" "notification_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "notification_put_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "notification_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_options.http_method
  status_code = aws_api_gateway_method_response.notification_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.notification_options_200]
}


 resource "aws_api_gateway_integration_response" "notification_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_get.http_method
  status_code = aws_api_gateway_method_response.notification_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "notification_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_post.http_method
  status_code = aws_api_gateway_method_response.notification_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

 resource "aws_api_gateway_integration_response" "notification_put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.notification.id
  http_method = aws_api_gateway_method.notification_put.http_method
  status_code = aws_api_gateway_method_response.notification_put_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "cp_ui_notification_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_notification"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "appointment_email" {
   parent_id   = aws_api_gateway_resource.appointment.id
   path_part   = "email"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "appointment_email_manual_review_id" {
   parent_id   = aws_api_gateway_resource.appointment_email.id
   path_part   = "{manual_review_id}"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "appointment_email_manual_review_id_action" {
   parent_id   = aws_api_gateway_resource.appointment_email_manual_review_id.id
   path_part   = "{action}"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "appointment_email_manual_review_id_action_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "appointment_email_manual_review_id_action_get" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method   = "GET"
  authorization = "NONE"
  # authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}

resource "aws_api_gateway_method" "appointment_email_manual_review_id_action_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method   = "POST"
  authorization = "NONE"
  # authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}

resource "aws_api_gateway_integration" "appointment_email_manual_review_id_action_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method = aws_api_gateway_method.appointment_email_manual_review_id_action_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.appointment_email_manual_review_id_action_options]
}


resource "aws_api_gateway_integration" "appointment_email_manual_review_id_action_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method = aws_api_gateway_method.appointment_email_manual_review_id_action_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.appt_emailrsp_manual_review.arn}/invocations"
}

resource "aws_api_gateway_integration" "appointment_email_manual_review_id_action_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method = aws_api_gateway_method.appointment_email_manual_review_id_action_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.appt_emailrsp_manual_review.arn}/invocations"
}


resource "aws_api_gateway_method_response" "appointment_email_manual_review_id_action_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method = aws_api_gateway_method.appointment_email_manual_review_id_action_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.appointment_email_manual_review_id_action_options]
}


resource "aws_api_gateway_method_response" "appointment_email_manual_review_id_action_get_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method = aws_api_gateway_method.appointment_email_manual_review_id_action_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_method_response" "appointment_email_manual_review_id_action_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method = aws_api_gateway_method.appointment_email_manual_review_id_action_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "appointment_email_manual_review_id_action_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method = aws_api_gateway_method.appointment_email_manual_review_id_action_options.http_method
  status_code = aws_api_gateway_method_response.appointment_email_manual_review_id_action_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.appointment_email_manual_review_id_action_options_200]
}


 resource "aws_api_gateway_integration_response" "appointment_email_manual_review_id_action_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method = aws_api_gateway_method.appointment_email_manual_review_id_action_get.http_method
  status_code = aws_api_gateway_method_response.appointment_email_manual_review_id_action_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

 resource "aws_api_gateway_integration_response" "appointment_email_manual_review_id_action_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.appointment_email_manual_review_id_action.id
  http_method = aws_api_gateway_method.appointment_email_manual_review_id_action_post.http_method
  status_code = aws_api_gateway_method_response.appointment_email_manual_review_id_action_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "appt_emailrsp_manual_review_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "appt_emailrsp_manual_review"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "tenant-customisation" {
   parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id
   path_part   = "tenant-customisation"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "tenant-customisation_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.tenant-customisation.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "tenant-customisation_get" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.tenant-customisation.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "tenant-customisation_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.tenant-customisation.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "tenant-customisation_put" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.tenant-customisation.id
  http_method   = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "tenant-customisation_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.tenant-customisation_options]
}


resource "aws_api_gateway_integration" "tenant-customisation_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_tenant_customisation.arn}/invocations"
}


resource "aws_api_gateway_integration" "tenant-customisation_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_tenant_customisation.arn}/invocations"
}


resource "aws_api_gateway_integration" "tenant-customisation_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_put.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_tenant_customisation.arn}/invocations"
}


resource "aws_api_gateway_method_response" "tenant-customisation_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.tenant-customisation_options]
}


resource "aws_api_gateway_method_response" "tenant-customisation_get_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "tenant-customisation_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "tenant-customisation_put_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "tenant-customisation_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_options.http_method
  status_code = aws_api_gateway_method_response.tenant-customisation_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.tenant-customisation_options_200]
}


 resource "aws_api_gateway_integration_response" "tenant-customisation_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_get.http_method
  status_code = aws_api_gateway_method_response.tenant-customisation_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "tenant-customisation_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_post.http_method
  status_code = aws_api_gateway_method_response.tenant-customisation_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "tenant-customisation_put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.tenant-customisation.id
  http_method = aws_api_gateway_method.tenant-customisation_put.http_method
  status_code = aws_api_gateway_method_response.tenant-customisation_put_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "cp_ui_tenant_customisation_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "cp_ui_tenant_customisation"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.customer_portal.execution_arn}/*"
}

resource "aws_api_gateway_resource" "locations_search" {
   parent_id   = aws_api_gateway_resource.locations.id
   path_part   = "search"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "locations_search_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_search.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "locations_search_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_search.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "locations_search_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_search.id
  http_method = aws_api_gateway_method.locations_search_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.locations_search_options]
}


resource "aws_api_gateway_integration" "locations_search_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_search.id
  http_method = aws_api_gateway_method.locations_search_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_open_dock_loc_config.arn}/invocations"
}


resource "aws_api_gateway_method_response" "locations_search_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_search.id
  http_method = aws_api_gateway_method.locations_search_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.locations_search_options]
}


resource "aws_api_gateway_method_response" "locations_search_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_search.id
  http_method = aws_api_gateway_method.locations_search_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "locations_search_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_search.id
  http_method = aws_api_gateway_method.locations_search_options.http_method
  status_code = aws_api_gateway_method_response.locations_search_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.locations_search_options_200]
}


 resource "aws_api_gateway_integration_response" "locations_search_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_search.id
  http_method = aws_api_gateway_method.locations_search_post.http_method
  status_code = aws_api_gateway_method_response.locations_search_post_response.status_code

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

resource "aws_api_gateway_resource" "locations_config" {
   parent_id   = aws_api_gateway_resource.locations.id
   path_part   = "config"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "locations_config_base" {
   parent_id   = aws_api_gateway_resource.locations_config.id
   path_part   = "base"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "locations_config_base_m_loc_id" {
   parent_id   = aws_api_gateway_resource.locations_config_base.id
   path_part   = "{m_loc_id}"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "locations_config_base_m_loc_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "locations_config_base_m_loc_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "locations_config_base_m_loc_id_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "locations_config_base_m_loc_id_put" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method   = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "locations_config_base_m_loc_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.locations_config_base_m_loc_id_options]
}


resource "aws_api_gateway_integration" "locations_config_base_m_loc_id_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_open_dock_loc_config.arn}/invocations"
}


resource "aws_api_gateway_integration" "locations_config_base_m_loc_id_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_open_dock_loc_config.arn}/invocations"
}


resource "aws_api_gateway_integration" "locations_config_base_m_loc_id_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_put.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_open_dock_loc_config.arn}/invocations"
}


resource "aws_api_gateway_method_response" "locations_config_base_m_loc_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.locations_config_base_m_loc_id_options]
}


resource "aws_api_gateway_method_response" "locations_config_base_m_loc_id_get_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "locations_config_base_m_loc_id_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "locations_config_base_m_loc_id_put_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "locations_config_base_m_loc_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_options.http_method
  status_code = aws_api_gateway_method_response.locations_config_base_m_loc_id_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.locations_config_base_m_loc_id_options_200]
}


 resource "aws_api_gateway_integration_response" "locations_config_base_m_loc_id_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_get.http_method
  status_code = aws_api_gateway_method_response.locations_config_base_m_loc_id_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "locations_config_base_m_loc_id_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_post.http_method
  status_code = aws_api_gateway_method_response.locations_config_base_m_loc_id_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "locations_config_base_m_loc_id_put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_base_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_base_m_loc_id_put.http_method
  status_code = aws_api_gateway_method_response.locations_config_base_m_loc_id_put_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_resource" "locations_config_tenant" {
   parent_id   = aws_api_gateway_resource.locations_config.id
   path_part   = "tenant"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}
resource "aws_api_gateway_resource" "locations_config_tenant_m_loc_id" {
   parent_id   = aws_api_gateway_resource.locations_config_tenant.id
   path_part   = "{m_loc_id}"
   rest_api_id = aws_api_gateway_rest_api.customer_portal.id
}

resource "aws_api_gateway_method" "locations_config_tenant_m_loc_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
    

resource "aws_api_gateway_method" "locations_config_tenant_m_loc_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "locations_config_tenant_m_loc_id_post" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_method" "locations_config_tenant_m_loc_id_put" {
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method   = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}


resource "aws_api_gateway_integration" "locations_config_tenant_m_loc_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.locations_config_tenant_m_loc_id_options]
}


resource "aws_api_gateway_integration" "locations_config_tenant_m_loc_id_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_open_dock_loc_config.arn}/invocations"
}


resource "aws_api_gateway_integration" "locations_config_tenant_m_loc_id_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_open_dock_loc_config.arn}/invocations"
}


resource "aws_api_gateway_integration" "locations_config_tenant_m_loc_id_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_put.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.cp_ui_open_dock_loc_config.arn}/invocations"
}


resource "aws_api_gateway_method_response" "locations_config_tenant_m_loc_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  depends_on = [aws_api_gateway_method.locations_config_tenant_m_loc_id_options]
}


resource "aws_api_gateway_method_response" "locations_config_tenant_m_loc_id_get_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "locations_config_tenant_m_loc_id_post_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_method_response" "locations_config_tenant_m_loc_id_put_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "locations_config_tenant_m_loc_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_options.http_method
  status_code = aws_api_gateway_method_response.locations_config_tenant_m_loc_id_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.locations_config_tenant_m_loc_id_options_200]
}


 resource "aws_api_gateway_integration_response" "locations_config_tenant_m_loc_id_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_get.http_method
  status_code = aws_api_gateway_method_response.locations_config_tenant_m_loc_id_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "locations_config_tenant_m_loc_id_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_post.http_method
  status_code = aws_api_gateway_method_response.locations_config_tenant_m_loc_id_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


 resource "aws_api_gateway_integration_response" "locations_config_tenant_m_loc_id_put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_tenant_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_tenant_m_loc_id_put.http_method
  status_code = aws_api_gateway_method_response.locations_config_tenant_m_loc_id_put_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
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


 resource "aws_api_gateway_integration_response" "locations_config_final_m_loc_id_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.locations_config_final_m_loc_id.id
  http_method = aws_api_gateway_method.locations_config_final_m_loc_id_get.http_method
  status_code = aws_api_gateway_method_response.locations_config_final_m_loc_id_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


