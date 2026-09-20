variable "name" {
  description = "Name prefix for regional networking resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition = (
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", var.vpc_cidr)) &&
      can(cidrhost(var.vpc_cidr, 0))
    )
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used by the regional subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }

  validation {
    condition     = length(distinct(var.availability_zones)) == length(var.availability_zones)
    error_message = "Availability Zones must not contain duplicates."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one for each Availability Zone."
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_cidrs) >= 2 &&
      alltrue([
        for cidr in var.public_subnet_cidrs :
        can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", cidr)) &&
        can(cidrhost(cidr, 0))
      ])
    )
    error_message = "Provide at least two valid public subnet CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one for each Availability Zone."
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_cidrs) >= 2 &&
      alltrue([
        for cidr in var.private_subnet_cidrs :
        can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", cidr)) &&
        can(cidrhost(cidr, 0))
      ])
    )
    error_message = "Provide at least two valid private subnet CIDRs."
  }
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
