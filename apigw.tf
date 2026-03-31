module "label_api" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "university"
  stage     = "dev"
  name      = "courses-api"
}

resource "aws_api_gateway_rest_api" "this" {
  name = module.label_api.id
}

resource "aws_api_gateway_resource" "authors" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "authors"
}

resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "courses"
}

resource "aws_api_gateway_resource" "course_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.courses.id
  path_part   = "{id}"
}

locals {
  methods = {
    "get_authors"   = { res_id = aws_api_gateway_resource.authors.id,   method = "GET",    lambda = aws_lambda_function.get_all_authors.invoke_arn, template = null }
    "get_courses"   = { res_id = aws_api_gateway_resource.courses.id,   method = "GET",    lambda = aws_lambda_function.get_all_courses.invoke_arn, template = null }
    "post_courses"  = { res_id = aws_api_gateway_resource.courses.id,   method = "POST",   lambda = aws_lambda_function.save_course.invoke_arn,     template = null }
    "get_course"    = { res_id = aws_api_gateway_resource.course_id.id, method = "GET",    lambda = aws_lambda_function.get_course.invoke_arn,      template = null }
    "delete_course" = { res_id = aws_api_gateway_resource.course_id.id, method = "DELETE", lambda = aws_lambda_function.delete_course.invoke_arn,   template = null }
    
    "put_course" = {
      res_id   = aws_api_gateway_resource.course_id.id
      method   = "PUT"
      lambda   = aws_lambda_function.update_course.invoke_arn
      template = <<EOF
{
  "id": "$input.params('id')",
  "title": $input.json('$.title'),
  "authorId": $input.json('$.authorId'),
  "length": $input.json('$.length'),
  "category": $input.json('$.category'),
  "watchHref": $input.json('$.watchHref')
}
EOF
    }
  }

  cors_resources = {
    "authors"   = aws_api_gateway_resource.authors.id
    "courses"   = aws_api_gateway_resource.courses.id
    "course_id" = aws_api_gateway_resource.course_id.id
  }
}

resource "aws_api_gateway_method" "method" {
  for_each      = local.methods
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value.res_id
  http_method   = each.value.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  for_each                = local.methods
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = each.value.res_id
  http_method             = aws_api_gateway_method.method[each.key].http_method
  integration_http_method = "POST" 
  type                    = "AWS"
  uri                     = each.value.lambda

  request_templates = each.value.template != null ? {
    "application/json" = each.value.template
  } : null
}

resource "aws_api_gateway_method_response" "response_200" {
  for_each    = local.methods
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.res_id
  http_method = aws_api_gateway_method.method[each.key].http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  for_each    = local.methods
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.res_id
  http_method = aws_api_gateway_method.method[each.key].http_method
  status_code = aws_api_gateway_method_response.response_200[each.key].status_code
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on = [aws_api_gateway_integration.integration]
}

# --- БЛОК АВТОГЕНЕРАЦІЇ CORS (OPTIONS) ---
resource "aws_api_gateway_method" "cors" {
  for_each      = local.cors_resources
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors" {
  for_each    = local.cors_resources
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value
  http_method = aws_api_gateway_method.cors[each.key].http_method
  type        = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_method_response" "cors" {
  for_each    = local.cors_resources
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value
  http_method = aws_api_gateway_method.cors[each.key].http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  for_each    = local.cors_resources
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value
  http_method = aws_api_gateway_method.cors[each.key].http_method
  status_code = aws_api_gateway_method_response.cors[each.key].status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.cors]
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.authors.id, aws_api_gateway_resource.courses.id, aws_api_gateway_resource.course_id.id,
      aws_api_gateway_method.method, aws_api_gateway_integration.integration, aws_api_gateway_method.cors
    ]))
  }
  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "v1"
}

output "api_url" {
  description = "Головний URL твого API Gateway"
  value       = aws_api_gateway_stage.v1.invoke_url
}