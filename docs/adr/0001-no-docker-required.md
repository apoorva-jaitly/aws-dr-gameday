# ADR 0001: Do Not Require Docker

- **Status:** Accepted
- **Date:** 2026-09-17

## Context

AWS DR GameDay needs deployable application and automation components, but its
development environment cannot depend on Docker Desktop, Docker Engine,
Kubernetes, Minikube, LocalStack, or another local container runtime. The
project should remain inexpensive, easy to reproduce, and clear in technical
interviews.

## Decision

Application and automation components will use supported Python AWS Lambda
runtimes and ZIP deployment packages. Terraform will provision AWS resources,
and packaging scripts will build deterministic ZIP artifacts from source and
dependencies without requiring a container image.

AWS-native managed services will be preferred over locally emulated cloud
services. Tests that do not require AWS will run directly with Python; cloud
integration tests will target a controlled development AWS environment.

## Consequences

### Benefits

- No local container runtime or image registry workflow is required.
- ZIP artifacts and Lambda configuration are compact and easy to demonstrate.
- Event-driven workloads can scale to zero, reducing development idle cost.
- Fewer platform components reduce initial operational overhead.
- Patching of the underlying Lambda runtime environment is AWS-managed.

### Trade-offs

- Lambda has execution-duration, runtime, ephemeral-storage, and deployment
  package constraints.
- Native dependencies must be compatible with the selected Lambda runtime and
  architecture; Lambda layers or a controlled non-container build process may
  be needed.
- ZIP deployments provide less runtime portability than OCI images.
- Long-running, stateful, highly customized, or daemon-style workloads may be
  a poor fit.
- Local execution does not perfectly reproduce the managed Lambda environment,
  so tests must separate unit behavior from AWS integration behavior.

## Alternatives considered

- **Lambda container images:** allow larger packages and custom runtimes, but
  require an image build/publish workflow and do not satisfy the no-Docker
  development constraint.
- **ECS or EKS:** provide broader workload flexibility but add cost,
  infrastructure, and operational complexity that Phase 1 does not need.
- **LocalStack or local Kubernetes:** can emulate parts of the platform but
  require a local container runtime and may differ from actual AWS behavior.

## Revisit criteria

Reconsider this decision if a future workload cannot reasonably meet Lambda
limits, needs persistent processes, or requires dependencies that cannot be
packaged reliably as ZIP artifacts. Such a change must remain optional for
local contributors or include a supported non-Docker build path.
