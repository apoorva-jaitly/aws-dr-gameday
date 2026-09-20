mock_provider "aws" {
  alias = "primary"
}

mock_provider "aws" {
  alias = "dr"
}

run "valid_phase1_configuration" {
  command = plan
}

run "rejects_overlapping_vpc_cidrs" {
  command = plan

  variables {
    dr_vpc_cidr             = "10.10.0.0/16"
    dr_public_subnet_cidrs  = ["10.10.20.0/24", "10.10.21.0/24"]
    dr_private_subnet_cidrs = ["10.10.30.0/24", "10.10.31.0/24"]
  }

  expect_failures = [
    terraform_data.configuration_validation,
  ]
}
