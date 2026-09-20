# ADR 0002: Preserve VPC Block Public Access

- **Status:** Accepted
- **Date:** 2026-09-18

## Context

VPC Block Public Access (BPA) is an account-level AWS network control that can
block Internet Gateway traffic across VPCs, independent of subnet routes,
public IP addresses, and security-group rules. Post-deployment verification
found `InternetGatewayBlockMode = block-ingress` in both `us-east-1` and
`us-west-2`.

Phase 1 creates public route tables with `0.0.0.0/0` routes to Internet
Gateways, but those routes do not make workloads publicly reachable while BPA
blocks Internet Gateway ingress. Public reachability would also require an
addressable workload and explicitly permitted security controls.

## Decision

The project will leave the account-level BPA setting unchanged. It is a
defense-in-depth control with a scope wider than this project, and changing it
would weaken protections for other resources in the account.

Phase 2 will prefer AWS-managed or serverless ingress and will not require a
publicly reachable EC2 instance. If a future workload genuinely requires
Internet Gateway ingress, it must use an explicitly reviewed BPA exclusion or
an alternative architecture appropriate to the workload and account security
policy.

## Consequences

- Phase 1 public subnets and routes represent network topology, not guaranteed
  public reachability.
- Tests and runbooks must account for BPA when evaluating ingress paths.
- Future designs should preserve the account security boundary by default.
- Any BPA exclusion requires explicit security review, narrow scope, and
  documented justification.
