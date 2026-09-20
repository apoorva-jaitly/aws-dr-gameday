resource "terraform_data" "configuration_validation" {
  lifecycle {
    precondition {
      condition     = var.primary_region != var.dr_region
      error_message = "primary_region and dr_region must be different."
    }

    precondition {
      condition = alltrue([
        for az in var.primary_availability_zones :
        can(regex("^${var.primary_region}[a-z]$", az))
      ])
      error_message = "Every primary Availability Zone must belong to primary_region."
    }

    precondition {
      condition = alltrue([
        for az in var.dr_availability_zones :
        can(regex("^${var.dr_region}[a-z]$", az))
      ])
      error_message = "Every DR Availability Zone must belong to dr_region."
    }

    precondition {
      condition     = length(var.primary_public_subnet_cidrs) == length(var.primary_availability_zones)
      error_message = "The primary public subnet CIDR count must match the primary Availability Zone count."
    }

    precondition {
      condition     = length(var.primary_private_subnet_cidrs) == length(var.primary_availability_zones)
      error_message = "The primary private subnet CIDR count must match the primary Availability Zone count."
    }

    precondition {
      condition     = length(var.dr_public_subnet_cidrs) == length(var.dr_availability_zones)
      error_message = "The DR public subnet CIDR count must match the DR Availability Zone count."
    }

    precondition {
      condition     = length(var.dr_private_subnet_cidrs) == length(var.dr_availability_zones)
      error_message = "The DR private subnet CIDR count must match the DR Availability Zone count."
    }

    precondition {
      condition     = length(distinct(local.primary_subnet_cidrs)) == length(local.primary_subnet_cidrs)
      error_message = "All primary-region public and private subnet CIDRs must be unique."
    }

    precondition {
      condition     = length(distinct(local.dr_subnet_cidrs)) == length(local.dr_subnet_cidrs)
      error_message = "All DR-region public and private subnet CIDRs must be unique."
    }

    precondition {
      condition = (
        local.primary_vpc_range.end < local.dr_vpc_range.start ||
        local.dr_vpc_range.end < local.primary_vpc_range.start
      )
      error_message = "The primary and DR VPC CIDRs must not overlap."
    }
  }
}
