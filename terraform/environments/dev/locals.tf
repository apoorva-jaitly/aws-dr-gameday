locals {
  common_tags = merge(var.additional_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })

  primary_subnet_cidrs = concat(
    var.primary_public_subnet_cidrs,
    var.primary_private_subnet_cidrs
  )
  dr_subnet_cidrs = concat(
    var.dr_public_subnet_cidrs,
    var.dr_private_subnet_cidrs
  )

  primary_vpc_range = {
    start = sum([
      for index, octet in split(".", cidrhost(var.primary_vpc_cidr, 0)) :
      tonumber(octet) * pow(256, 3 - index)
    ])
    end = sum([
      for index, octet in split(".", cidrhost(var.primary_vpc_cidr, -1)) :
      tonumber(octet) * pow(256, 3 - index)
    ])
  }

  dr_vpc_range = {
    start = sum([
      for index, octet in split(".", cidrhost(var.dr_vpc_cidr, 0)) :
      tonumber(octet) * pow(256, 3 - index)
    ])
    end = sum([
      for index, octet in split(".", cidrhost(var.dr_vpc_cidr, -1)) :
      tonumber(octet) * pow(256, 3 - index)
    ])
  }
}
