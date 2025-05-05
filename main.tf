
# proveedor del aws
provider "aws" {
  region  = var.region  # Usamos la región definida en las variables
  profile = "proyecto_quintana"
}

# S3 para plantillas de correo
resource "aws_s3_bucket" "email_templates" {
  bucket = var.email_templates_bucket
  force_destroy = true

  tags = {
    Purpose = "Email Templates"
  }
}

# DynamoDB Table para clientes
resource "aws_dynamodb_table" "clients" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST" # Modo más económico para cargas variables/bajas
  hash_key     = "client_name" # Clave primaria

  attribute {
    name = "client_name"
    type = "S"
  }

  # Configuración adicional para optimizar costos
  ttl {
    attribute_name = ""  # Desactivado
    enabled        = false
  }

  # Opciones que reducen costos
  point_in_time_recovery {
    enabled = false  # se desactiva backups automáticos (reduce costos)
  }

  server_side_encryption {
    enabled = true  # Encriptacion por defecto (sin costo adicional)
  }
}


# Ítem inicial con datos de usuario para pruebas
resource "aws_dynamodb_table_item" "client_initial" {
  table_name = aws_dynamodb_table.clients.name
  hash_key   = aws_dynamodb_table.clients.hash_key

  # Usuario de prueba para envío de correo
  item = <<ITEM
{
  "client_name": {"S": "sergio"},
  "email": {"S": "sergiogg1259@gmail.com"} 
}
ITEM
}

# Otro item de prueba para otro usuario
resource "aws_dynamodb_table_item" "other_client" {
  table_name = aws_dynamodb_table.clients.name
  hash_key   = aws_dynamodb_table.clients.hash_key

  # Usuario de prueba para envío de correo
  item = <<ITEM
{
  "client_name": {"S": "otro cliente"},
  "email": {"S": "l_guanilo_e@hotmail.com"} 
}
ITEM
}


# Cola SQS
resource "aws_sqs_queue" "email_queue" {
  name                        = var.sqs_queue_name
  visibility_timeout_seconds   = 30
  message_retention_seconds    = 900
  max_message_size             = 51200
  delay_seconds                = 0
}

# Lambda para preparar los correos
resource "aws_lambda_function" "prepare_emails" {
  function_name = "prepare_emails"
  role          = aws_iam_role.lambda_prepare_emails_role.arn
  runtime       = "python3.9"
  handler       = "prepare_emails.lambda_handler"

  filename         = "${path.module}/codes/prepare_emails.zip"
  source_code_hash = filebase64sha256("${path.module}/codes/prepare_emails.zip")

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout
}

# API Gateway para enviar correos
resource "aws_api_gateway_rest_api" "quintana_api" {
  name        = "quintana-gateway"
  description = "API Gateway para Constructora Quintana"
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}

resource "aws_api_gateway_resource" "send_email_resource" {
  rest_api_id = aws_api_gateway_rest_api.quintana_api.id
  parent_id   = aws_api_gateway_rest_api.quintana_api.root_resource_id
  path_part   = "send-email"
}

resource "aws_api_gateway_method" "post_send_email" {
  rest_api_id   = aws_api_gateway_rest_api.quintana_api.id
  resource_id   = aws_api_gateway_resource.send_email_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "post_send_email_response" {
  rest_api_id = aws_api_gateway_rest_api.quintana_api.id
  resource_id = aws_api_gateway_resource.send_email_resource.id
  http_method = aws_api_gateway_method.post_send_email.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = var.cors_headers
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.quintana_api.id
  resource_id             = aws_api_gateway_resource.send_email_resource.id
  http_method             = aws_api_gateway_method.post_send_email.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.prepare_emails.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.prepare_emails.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.quintana_api.execution_arn}/*/*/*"
}
