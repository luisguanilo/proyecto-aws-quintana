# Región de AWS
variable "region" {
  description = "La región de AWS"
  type        = string
  default     = "us-east-1"
}

# Entorno de la infraestructura (dev, prod)
variable "environment" {
  description = "El entorno de la infraestructura (dev, prod)"
  type        = string
  default     = "dev"
}

# Configuración de SES
variable "ses_email" {
  description = "Correo electrónico de identidad SES"
  type        = string
  default     = "guanilo99@gmail.com"
}

# Configuración del bucket de S3
variable "email_templates_bucket" {
  description = "Nombre del bucket S3 para plantillas de correo"
  type        = string
}

# Configuración de DynamoDB
variable "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}

# Configuración de la cola SQS
variable "sqs_queue_name" {
  description = "Nombre de la cola SQS"
  type        = string
}

# Configuración de Lambda
variable "lambda_memory_size" {
  description = "Tamaño de la memoria para Lambda"
  type        = number
  default     = 200
}

variable "lambda_timeout" {
  description = "Tiempo de espera para la función Lambda"
  type        = number
  default     = 10 
}

# Diccionario de configuración CORS para API Gateway
variable "cors_headers" {
  description = "Configuración CORS para la API Gateway"
  type = map(string)
  default = {
    "Access-Control-Allow-Origin"  = "'*'"
    "Access-Control-Allow-Methods" = "'POST, OPTIONS'"
    "Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

