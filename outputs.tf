# Exponer outputs clave para el proyecto

# ARN de la función Lambda que prepara los correos
output "prepare_emails_lambda_arn" {
  description = "ARN de la función Lambda que prepara los correos"
  value       = aws_lambda_function.prepare_emails.arn
}

# URL de la API Gateway
output "api_gateway_url" {
  description = "URL de la API Gateway"
  value       = "${aws_api_gateway_rest_api.quintana_api.execution_arn}/send-email"
}

# Nombre del bucket S3
output "email_templates_bucket" {
  description = "Nombre del bucket S3 para plantillas de correo"
  value       = aws_s3_bucket.email_templates.bucket
}

# URL de la cola SQS
output "sqs_queue_url" {
  description = "URL de la cola SQS"
  value       = aws_sqs_queue.email_queue.url
}
