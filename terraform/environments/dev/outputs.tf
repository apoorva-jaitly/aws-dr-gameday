output "primary_networking" {
  description = "Important networking resource IDs in the primary region."
  value = {
    region                  = var.primary_region
    vpc_id                  = module.primary_networking.vpc_id
    vpc_cidr                = module.primary_networking.vpc_cidr
    internet_gateway_id     = module.primary_networking.internet_gateway_id
    public_subnet_ids       = module.primary_networking.public_subnet_ids
    private_subnet_ids      = module.primary_networking.private_subnet_ids
    public_route_table_id   = module.primary_networking.public_route_table_id
    private_route_table_ids = module.primary_networking.private_route_table_ids
  }
}

output "dr_networking" {
  description = "Important networking resource IDs in the DR region."
  value = {
    region                  = var.dr_region
    vpc_id                  = module.dr_networking.vpc_id
    vpc_cidr                = module.dr_networking.vpc_cidr
    internet_gateway_id     = module.dr_networking.internet_gateway_id
    public_subnet_ids       = module.dr_networking.public_subnet_ids
    private_subnet_ids      = module.dr_networking.private_subnet_ids
    public_route_table_id   = module.dr_networking.public_route_table_id
    private_route_table_ids = module.dr_networking.private_route_table_ids
  }
}

output "primary_api_url" {
  description = "Directly usable primary regional API URL."
  value       = module.primary_application.api_url
}

output "dr_api_url" {
  description = "Directly usable DR regional API URL."
  value       = module.dr_application.api_url
}

output "primary_lambda_name" {
  description = "Primary regional Lambda function name."
  value       = module.primary_application.lambda_name
}

output "dr_lambda_name" {
  description = "DR regional Lambda function name."
  value       = module.dr_application.lambda_name
}

output "primary_lambda_arn" {
  description = "Primary regional Lambda function ARN."
  value       = module.primary_application.lambda_arn
}

output "dr_lambda_arn" {
  description = "DR regional Lambda function ARN."
  value       = module.dr_application.lambda_arn
}
