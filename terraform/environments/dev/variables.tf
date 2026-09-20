variable "project_name" {
  description = "Project identifier used in names and tags."
  type        = string
  default     = "aws-dr-gameday"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "primary_region" {
  description = "AWS region serving as the primary region."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.primary_region))
    error_message = "primary_region must be a valid AWS region identifier."
  }
}

variable "dr_region" {
  description = "AWS region serving as the disaster recovery region."
  type        = string
  default     = "us-west-2"

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.dr_region))
    error_message = "dr_region must be a valid AWS region identifier."
  }
}

variable "primary_vpc_cidr" {
  description = "CIDR block for the primary-region VPC."
  type        = string
  default     = "10.10.0.0/16"

  validation {
    condition = (
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", var.primary_vpc_cidr)) &&
      can(cidrhost(var.primary_vpc_cidr, 0))
    )
    error_message = "primary_vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "dr_vpc_cidr" {
  description = "CIDR block for the DR-region VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition = (
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", var.dr_vpc_cidr)) &&
      can(cidrhost(var.dr_vpc_cidr, 0))
    )
    error_message = "dr_vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "primary_availability_zones" {
  description = "Availability Zones for primary-region subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.primary_availability_zones) >= 2
    error_message = "At least two primary Availability Zones are required."
  }

  validation {
    condition     = length(distinct(var.primary_availability_zones)) == length(var.primary_availability_zones)
    error_message = "primary_availability_zones must not contain duplicates."
  }
}

variable "dr_availability_zones" {
  description = "Availability Zones for DR-region subnets."
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]

  validation {
    condition     = length(var.dr_availability_zones) >= 2
    error_message = "At least two DR Availability Zones are required."
  }

  validation {
    condition     = length(distinct(var.dr_availability_zones)) == length(var.dr_availability_zones)
    error_message = "dr_availability_zones must not contain duplicates."
  }
}

variable "primary_public_subnet_cidrs" {
  description = "Public subnet CIDRs for the primary region."
  type        = list(string)
  default     = ["10.10.0.0/24", "10.10.1.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.primary_public_subnet_cidrs :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", cidr)) &&
      can(cidrhost(cidr, 0))
    ])
    error_message = "Every primary public subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "primary_private_subnet_cidrs" {
  description = "Private subnet CIDRs for the primary region."
  type        = list(string)
  default     = ["10.10.10.0/24", "10.10.11.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.primary_private_subnet_cidrs :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", cidr)) &&
      can(cidrhost(cidr, 0))
    ])
    error_message = "Every primary private subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "dr_public_subnet_cidrs" {
  description = "Public subnet CIDRs for the DR region."
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.dr_public_subnet_cidrs :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", cidr)) &&
      can(cidrhost(cidr, 0))
    ])
    error_message = "Every DR public subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "dr_private_subnet_cidrs" {
  description = "Private subnet CIDRs for the DR region."
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.dr_private_subnet_cidrs :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", cidr)) &&
      can(cidrhost(cidr, 0))
    ])
    error_message = "Every DR private subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "additional_tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "application_service_name" {
  description = "Service name reported by both regional APIs."
  type        = string
  default     = "dr-gameday-api"
}

variable "application_version" {
  description = "Application version deployed to both regions."
  type        = string
  default     = "1.0.0"
}

variable "application_log_retention_days" {
  description = "CloudWatch log retention for both regional Lambda functions."
  type        = number
  default     = 14
}
