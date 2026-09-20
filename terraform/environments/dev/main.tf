module "primary_networking" {
  source = "../../modules/networking"

  providers = {
    aws = aws.primary
  }

  name                 = "${var.project_name}-${var.environment}-primary"
  vpc_cidr             = var.primary_vpc_cidr
  availability_zones   = var.primary_availability_zones
  public_subnet_cidrs  = var.primary_public_subnet_cidrs
  private_subnet_cidrs = var.primary_private_subnet_cidrs
  tags                 = local.common_tags
}

module "dr_networking" {
  source = "../../modules/networking"

  providers = {
    aws = aws.dr
  }

  name                 = "${var.project_name}-${var.environment}-dr"
  vpc_cidr             = var.dr_vpc_cidr
  availability_zones   = var.dr_availability_zones
  public_subnet_cidrs  = var.dr_public_subnet_cidrs
  private_subnet_cidrs = var.dr_private_subnet_cidrs
  tags                 = local.common_tags
}

module "primary_application" {
  source = "../../modules/application"

  providers = {
    aws = aws.primary
  }

  name               = "${var.project_name}-${var.environment}-primary-api"
  source_dir         = "${path.root}/../../../application/src"
  deployment_region  = var.primary_region
  deployment_role    = "PRIMARY"
  service_name       = var.application_service_name
  service_version    = var.application_version
  log_retention_days = var.application_log_retention_days
  tags               = local.common_tags
}

module "dr_application" {
  source = "../../modules/application"

  providers = {
    aws = aws.dr
  }

  name               = "${var.project_name}-${var.environment}-dr-api"
  source_dir         = "${path.root}/../../../application/src"
  deployment_region  = var.dr_region
  deployment_role    = "DR"
  service_name       = var.application_service_name
  service_version    = var.application_version
  log_retention_days = var.application_log_retention_days
  tags               = local.common_tags
}
