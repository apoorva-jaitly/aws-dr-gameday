mock_provider "aws" {}

run "phase2a_application_contract" {
  command = plan

  variables {
    name              = "aws-dr-gameday-test-primary-api"
    source_dir        = "../../../application/src"
    deployment_region = "us-east-1"
    deployment_role   = "PRIMARY"
  }

  assert {
    condition     = length(aws_lambda_function.this.vpc_config) == 0
    error_message = "Phase 2A Lambda must remain outside the VPC."
  }

  assert {
    condition     = aws_iam_role_policy_attachment.lambda_logging.policy_arn == "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    error_message = "Lambda must receive only the basic CloudWatch logging managed policy."
  }

  assert {
    condition     = aws_lambda_permission.api_gateway.principal == "apigateway.amazonaws.com"
    error_message = "Only API Gateway should receive invoke permission."
  }

  assert {
    condition     = length(aws_apigatewayv2_route.get) == 4
    error_message = "Exactly the four Phase 2A GET routes must be configured."
  }
}
