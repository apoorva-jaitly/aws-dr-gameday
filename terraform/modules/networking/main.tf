locals {
  public_subnets = {
    for index in range(min(length(var.availability_zones), length(var.public_subnet_cidrs))) :
    var.availability_zones[index] => var.public_subnet_cidrs[index]
  }

  private_subnets = {
    for index in range(min(length(var.availability_zones), length(var.private_subnet_cidrs))) :
    var.availability_zones[index] => var.private_subnet_cidrs[index]
  }

  all_subnet_cidrs = concat(var.public_subnet_cidrs, var.private_subnet_cidrs)

  vpc_range = {
    start = sum([
      for index, octet in split(".", cidrhost(var.vpc_cidr, 0)) :
      tonumber(octet) * pow(256, 3 - index)
    ])
    end = sum([
      for index, octet in split(".", cidrhost(var.vpc_cidr, -1)) :
      tonumber(octet) * pow(256, 3 - index)
    ])
  }

  subnet_ranges = [
    for cidr in local.all_subnet_cidrs : {
      cidr = cidr
      start = sum([
        for index, octet in split(".", cidrhost(cidr, 0)) :
        tonumber(octet) * pow(256, 3 - index)
      ])
      end = sum([
        for index, octet in split(".", cidrhost(cidr, -1)) :
        tonumber(octet) * pow(256, 3 - index)
      ])
    }
  ]

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "networking"
  })
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-vpc"
  })

  lifecycle {
    precondition {
      condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
      error_message = "The public subnet CIDR count must match the Availability Zone count."
    }

    precondition {
      condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
      error_message = "The private subnet CIDR count must match the Availability Zone count."
    }

    precondition {
      condition = alltrue([
        for subnet in local.subnet_ranges :
        subnet.start >= local.vpc_range.start &&
        subnet.end <= local.vpc_range.end
      ])
      error_message = "Every public and private subnet CIDR must be fully contained within the VPC CIDR."
    }

    precondition {
      condition     = length(distinct(local.all_subnet_cidrs)) == length(local.all_subnet_cidrs)
      error_message = "Public and private subnet CIDRs must be unique within the region."
    }

    precondition {
      condition = alltrue(flatten([
        for index, subnet in local.subnet_ranges : [
          for other_index, other_subnet in local.subnet_ranges :
          index == other_index ||
          subnet.end < other_subnet.start ||
          other_subnet.end < subnet.start
        ]
      ]))
      error_message = "Public and private subnet CIDRs must not overlap within the region."
    }
  }
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress = []
  egress  = []

  tags = merge(local.common_tags, {
    Name = "${var.name}-default-sg-restricted"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.name}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-public-rt"
    Tier = "public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-${each.key}-rt"
    Tier = "private"
  })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
