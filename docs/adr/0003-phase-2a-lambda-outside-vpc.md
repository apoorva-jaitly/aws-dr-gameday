# ADR 0003: Keep the Phase 2A Lambda Application Outside the VPC

- **Status:** Accepted
- **Date:** 2026-09-20

## Context

The Phase 2A application exposes static operational endpoints through API
Gateway and writes logs to CloudWatch. It has no database, private service, or
other dependency reachable only through the Phase 1 VPC.

Attaching Lambda to private subnets would add network interfaces and security
group configuration without enabling a current requirement. Internet or
public AWS service access from such a function could also require paid NAT
Gateway capacity or additional VPC endpoints.

## Decision

The Phase 2A Lambda functions will not have a VPC configuration. API Gateway
will invoke each regional function directly, and the Lambda service will
deliver function logs to CloudWatch using the execution role.

## Consequences

- No NAT Gateway is required, avoiding hourly and data-processing cost.
- Deployment and troubleshooting remain simpler because there are no Lambda
  ENIs, subnet capacity concerns, routes, or security groups for the function.
- Phase 1 networking and account-level VPC Block Public Access remain
  unchanged.
- The application cannot directly reach a future private-only dependency until
  its connectivity is deliberately designed.

## Revisit criteria

VPC attachment becomes appropriate when the Lambda must reach a private
database, internal load balancer, private service endpoint, or another resource
whose access policy and network boundary require private connectivity. That
decision must identify subnets, security groups, DNS behavior, egress needs,
and whether VPC endpoints or another cost-conscious path can avoid a NAT
Gateway.
