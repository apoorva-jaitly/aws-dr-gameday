output "api_url" {
  description = "Directly usable base URL for the regional HTTP API."
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "lambda_name" {
  description = "Regional Lambda function name."
  value       = aws_lambda_function.this.function_name
}

output "lambda_arn" {
  description = "Regional Lambda function ARN."
  value       = aws_lambda_function.this.arn
}
