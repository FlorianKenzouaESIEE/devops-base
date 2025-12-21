output "api_endpoint" {
  description = "L'URL de l'API Gateway"
  value       = aws_apigatewayv2_api.api.api_endpoint
}