import json

dups=[]

end_points = [
    {
        "endpoint" : "locations/config/final/{m_loc_id}",
        "methods"  : ["POST", "GET"],
        "lambda"   : {
            "POST" : "cp_ui_open_dock_loc_config",
            "GET" : "cp_ui_open_dock_loc_config"
        }
    },
    {
        "endpoint" : "stop/{stop_id}",
        "methods"  : ["GET"],
        "lambda"   : {
            "GET" :'cp_ui_get_stop_detail'
        }
    }
]

meta = {}

def create_config_for_path(path, parent_path, meta):
    full_path = None
    if parent_path is None:
        return {
            'fp':path,
            'parent_path': parent_path, 'path_part' : path}
    else:
        path_with_out_braces = path.strip('{}')
        return {
            'fp':f'{parent_path}_{path_with_out_braces}',
            'parent_path': parent_path, 
            'path_part' : path
        }


def print_method(parent_path, full_path, path):
    if parent_path is None:
        print (f'resource "aws_api_gateway_resource" "{path}" {{')
        print (f'   parent_id   = aws_api_gateway_rest_api.customer_portal.root_resource_id')
    else:
        print (f'resource "aws_api_gateway_resource" "{full_path}" {{')
        print (f'   parent_id   = aws_api_gateway_resource.{parent_path}.id')
    print (f'   path_part   = "{path}"')
    print (f'   rest_api_id = aws_api_gateway_rest_api.customer_portal.id')
    print ("}")

def print_aws_api_gateway_method(val):
    if val.get('methods') is None:
        return
    
    options = f"""
resource "aws_api_gateway_method" "{val['fp']}_options" {{
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.{val['fp']}.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}}
    """
    print (options)
    for method in val.get('methods'):
        gw_method_str = f"""
resource "aws_api_gateway_method" "{val['fp']}_{method.lower()}" {{
  rest_api_id   = aws_api_gateway_rest_api.customer_portal.id
  resource_id   = aws_api_gateway_resource.{val['fp']}.id
  http_method   = "{method}"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.portal_authorizer.id
}}
"""
        if val['fp']+"_"+method.lower() not in dups:
            print (gw_method_str)
            dups.append(val['fp']+"_"+method.lower())

def print_aws_api_gateway_integration(val):
    if val.get('methods') is None:
        return
    
    options = f"""
resource "aws_api_gateway_integration" "{val['fp']}_options_integration" {{
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.{val['fp']}.id
  http_method = aws_api_gateway_method.{val['fp']}_options.http_method
  type        = "MOCK"
  request_templates = {{
    "application/json" = jsonencode(
      {{
        statusCode = 200
      }}
    )
  }}
  depends_on = [aws_api_gateway_method.{val['fp']}_options]
}}
"""
    print (options)
    for method in val.get('methods'):
        gw_integration = f"""
resource "aws_api_gateway_integration" "{val['fp']}_{method.lower()}_integration" {{
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.{val['fp']}.id
  http_method = aws_api_gateway_method.{val['fp']}_{method.lower()}.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${{data.aws_region.current.name}}:lambda:path/2015-03-31/functions/${{data.aws_lambda_function.{val['lambda'][method]}.arn}}/invocations"
}}
"""
        if val['fp']+"_"+method.lower()+"_integration" not in dups:
            print (gw_integration)
            dups.append(val['fp']+"_"+method.lower()+"_integration")

def print_aws_api_gateway_method_response(val):
    
    if val.get('methods') is None:
        return
    
    options = f"""
resource "aws_api_gateway_method_response" "{val['fp']}_options_200" {{
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.{val['fp']}.id
  http_method = aws_api_gateway_method.{val['fp']}_options.http_method
  status_code = "200"
  response_models = {{
    "application/json" = "Empty"
  }}
  response_parameters = {{
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }}
  depends_on = [aws_api_gateway_method.{val['fp']}_options]
}}
"""
    print (options)
    for method in val.get('methods'):
        gw_method_rsp = f"""
resource "aws_api_gateway_method_response" "{val['fp']}_{method.lower()}_response" {{
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.{val['fp']}.id
  http_method = aws_api_gateway_method.{val['fp']}_{method.lower()}.http_method
  status_code = "200"

  response_models = {{
    "application/json" = "Empty"
  }}
  response_parameters = {{
    "method.response.header.Access-Control-Allow-Origin" = false
  }}
}}
"""
        if val['fp']+"_"+method.lower()+"_response" not in dups:
            print (gw_method_rsp)
            dups.append(val['fp']+"_"+method.lower()+"_response")

def print_aws_api_gateway_integration_response(val):
    if val.get('methods') is None:
        return
    
    options = f"""
resource "aws_api_gateway_integration_response" "{val['fp']}_options_integration_response" {{
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.{val['fp']}.id
  http_method = aws_api_gateway_method.{val['fp']}_options.http_method
  status_code = aws_api_gateway_method_response.{val['fp']}_options_200.status_code

  response_parameters = {{
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }}
  depends_on = [aws_api_gateway_method_response.{val['fp']}_options_200]
}}
"""
    print (options)

    for method in val.get('methods'):
        gw_method_int_rsp = f"""
 resource "aws_api_gateway_integration_response" "{val['fp']}_{method.lower()}_integration_response" {{
  rest_api_id = aws_api_gateway_rest_api.customer_portal.id
  resource_id = aws_api_gateway_resource.{val['fp']}.id
  http_method = aws_api_gateway_method.{val['fp']}_{method.lower()}.http_method
  status_code = aws_api_gateway_method_response.{val['fp']}_{method.lower()}_response.status_code

  response_parameters = {{
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }}
}}
"""
        if val['fp']+"_"+method.lower()+"_integration_response" not in dups:
            print (gw_method_int_rsp)
            dups.append(val['fp']+"_"+method.lower()+"_integration_response")

def print_aws_lambda_permission(val):
    if val.get('lambda') is None:
        return
    
    for method in val.get('lambda'):
        lambda_method = val.get('lambda')[method]
        aws_lambda_permission = f"""
resource "aws_lambda_permission" "{lambda_method}_permission" {{
  action        = "lambda:InvokeFunction"
  function_name = "{lambda_method}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${{aws_api_gateway_rest_api.customer_portal.execution_arn}}/*"
}}
"""
        if lambda_method+"_permission" not in dups:
            print (aws_lambda_permission)
            dups.append(lambda_method+"_permission")

meta_aa = {}

for end_pt in end_points:
    endpoint_url_parts = end_pt["endpoint"].split("/")

    parent_path = None
    last_key = None
    for i in range(len(endpoint_url_parts)):

        if i==1:
            parent_path = endpoint_url_parts[i-1]
        elif i>1:
            parent_path = f'{parent_path}_{endpoint_url_parts[i-1]}'

        aa = create_config_for_path (endpoint_url_parts[i], parent_path, meta)
        last_key = aa['fp']
        if last_key not in meta_aa:
            meta_aa[last_key] = aa
    meta_aa[last_key]['methods'] = end_pt['methods']
    meta_aa[last_key]['lambda'] = end_pt['lambda']

    

print (json.dumps(meta_aa, indent=4))

for pt in meta_aa:
    val = meta_aa[pt]
    print_method(val['parent_path'], val['fp'], val['path_part'])
    print_aws_api_gateway_method(val)
    print_aws_api_gateway_integration(val)
    print_aws_api_gateway_method_response(val)
    print_aws_api_gateway_integration_response(val)
    print_aws_lambda_permission(val)
