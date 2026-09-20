mock_provider "aws" {}

variables {
  name                 = "phase1-test"
  vpc_cidr             = "10.10.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.10.0.0/24", "10.10.1.0/24"]
  private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
}

run "valid_regional_network" {
  command = plan
}

run "rejects_overlapping_subnets" {
  command = plan

  variables {
    private_subnet_cidrs = [
      "10.10.0.128/25",
      "10.10.11.0/24",
    ]
  }

  expect_failures = [
    aws_vpc.this,
  ]
}

run "rejects_subnet_outside_vpc" {
  command = plan

  variables {
    private_subnet_cidrs = [
      "10.11.10.0/24",
      "10.10.11.0/24",
    ]
  }

  expect_failures = [
    aws_vpc.this,
  ]
}
