# AWS DR GameDay

AWS DR GameDay is a production-minded, cost-conscious portfolio project for
building and exercising a multi-region disaster recovery (DR) platform on AWS.
It uses repeatable failure scenarios, automated recovery, observability, and
measured recovery objectives to demonstrate practical SRE and DevOps skills.

## Why this project exists

Disaster recovery plans are useful only when they can be tested. This project
will provide a safe environment for injecting controlled failures, observing
their impact, executing runbooks or automation, and comparing actual recovery
performance with target recovery time objective (RTO) and recovery point
objective (RPO).

Phase 1 created the reusable Terraform foundation and regional network
boundaries. Phase 2A adds identical, independently deployed serverless
applications in both regions. It does not add a database, DNS failover,
failure injector, or recovery automation.

## High-level architecture

- **Primary region (`us-east-1`)**: one VPC with public and private subnets
  distributed across two Availability Zones.
- **DR region (`us-west-2`)**: an independent VPC with the same subnet pattern.
- **Public routing**: each VPC has an Internet Gateway and a public route table.
- **Private routing**: private subnets have regional route tables but no default
  internet route in Phase 1.
- **Default security groups**: each VPC default security group is explicitly
  managed with no ingress or egress rules.
- **Phase 2A application**: an API Gateway HTTP API invokes a Python Lambda in
  each region, with logs retained in CloudWatch Logs.
- **Future phases**: a replicated data tier, health-based traffic failover,
  alarms, dashboards, event-driven recovery, and controlled failure injection.

See [architecture/architecture.md](architecture/architecture.md) for boundaries
and planned components.

## Technologies

- Terraform and the AWS provider for Infrastructure as Code
- AWS VPC networking across two regions
- Python and AWS Lambda ZIP packages for future application and automation
- Future AWS-native services such as CloudWatch, EventBridge, Route 53, and
  managed data replication

## Why Lambda instead of containers

Lambda ZIP deployments keep the project runnable without Docker, a container
runtime, or a local image build pipeline. They fit event-driven game-day
automation, have no idle compute charge, and are straightforward to explain and
deploy. The trade-offs include Lambda runtime, package-size, execution-duration,
and portability constraints. See
[docs/adr/0001-no-docker-required.md](docs/adr/0001-no-docker-required.md).

## Phase 2A architecture

```text
Primary us-east-1                 DR us-west-2

API Gateway HTTP API             API Gateway HTTP API
          |                                |
        Lambda                           Lambda
          |                                |
   CloudWatch Logs                 CloudWatch Logs
```

Terraform instantiates one reusable application module twice using the
`aws.primary` and `aws.dr` provider aliases. Both deployments package the same
`application/src` implementation. Environment variables identify the regional
role (`PRIMARY` or `DR`), service name, and version; the Lambda runtime supplies
its AWS region.

The functions intentionally remain outside both Phase 1 VPCs. They have no
private dependencies, so VPC attachment would add ENI, subnet, routing, and
security-group complexity without providing a current benefit. Keeping them
outside the VPC also avoids introducing a NAT Gateway for outbound access. See
[ADR 0003](docs/adr/0003-phase-2a-lambda-outside-vpc.md).

Docker is not required: the application uses only the Python standard library,
unit tests run directly with Python, and Terraform creates a Lambda ZIP archive
from the source directory.

### API responses

`GET /health`:

```json
{
  "service": "dr-gameday-api",
  "status": "healthy",
  "region": "us-east-1"
}
```

`GET /status` also returns `role` and `version`. The primary deployment reports
`PRIMARY` and `us-east-1`; the DR deployment reports `DR` and `us-west-2`.
`GET /version` returns the service version, and `GET /dependencies` reports the
database as `not_configured`. Unknown routes return HTTP 404 JSON.

## Why two regions

Availability Zones protect against localized failures; they do not demonstrate
regional disaster recovery. Separate VPCs in `us-east-1` and `us-west-2` create
independent failure domains and allow later phases to test cross-region data
replication, health-based failover, recovery automation, and regional recovery
objectives.

## Planned game-day scenarios

- Primary application endpoint degradation or unavailability
- Regional application failure and traffic failover
- Delayed or interrupted cross-region data replication
- Accidental application configuration failure
- Dependency or event-processing failure
- Alarm, runbook, or recovery-automation failure

Failure injection will be scoped, reversible, auditable, and protected by
explicit safety controls in a later phase.

## Planned RTO and RPO measurements

- **RTO**: time from a declared fault to restored service health in the DR
  region.
- **RPO**: age or count of data changes missing at the recovery point.
- CloudWatch metrics, structured logs, timestamps, synthetic checks, and
  game-day event records will provide the evidence. Target objectives will be
  defined per scenario before failure injection is implemented.

## Cost considerations

Phase 1 creates VPCs, subnets, route tables, and Internet Gateways. These
resources generally have no hourly charge, although standard AWS data-transfer
and public IPv4 charges can apply when later resources use them.

### Why Phase 1 has no NAT Gateway or VPC endpoints

NAT Gateways are deliberately omitted because they incur hourly and
per-gigabyte processing charges. VPC endpoints are also deferred because Phase
1 has no private workload that needs access to an AWS service, and many
interface endpoints incur hourly charges. Consequently, Phase 1 private
subnets intentionally have no outbound internet or private service path. A
later phase can add the minimum required connectivity after workload traffic
requirements are known and documented.

Review the Terraform plan and current AWS pricing before every deployment.

Phase 2A uses consumption-based API Gateway HTTP APIs, Lambda, and CloudWatch
Logs. Lambda memory and timeout are intentionally small, detailed API metrics
are disabled, and logs expire after 14 days by default. It adds no NAT Gateway,
load balancer, database, container service, or always-on compute.

## Phase 1 prerequisites

- Terraform `>= 1.6, < 2.0`
- An AWS account and locally configured AWS authentication (for example, AWS
  IAM Identity Center or environment-based credentials)
- Permission to manage the VPC resources in both configured regions

No credentials, account IDs, or secrets belong in this repository.

## Deploy the dev environment

```bash
make fmt
make validate
make plan
make apply
```

`make plan` is inspection-only and does not save a plan file. `make apply`
reruns formatting checks and validation, then creates a fresh interactive plan
for approval. This prevents an older saved plan from being applied
accidentally. Compare the fresh apply plan with the inspected plan before
approving it. To customize values, copy the example file:

```bash
cp terraform/environments/dev/terraform.tfvars.example \
  terraform/environments/dev/terraform.tfvars
```

The local Terraform state is ignored by Git. A secure remote state backend with
locking should be introduced before team or production use.

## Validate without deploying

The native Terraform tests use mocked AWS providers and do not call AWS:

```bash
make fmt
make validate
terraform -chdir=terraform/environments/dev test
terraform -chdir=terraform/modules/networking init -backend=false
terraform -chdir=terraform/modules/networking validate
terraform -chdir=terraform/modules/networking test
terraform -chdir=terraform/modules/application init -backend=false
terraform -chdir=terraform/modules/application validate
terraform -chdir=terraform/modules/application test
python3 -m unittest discover -s application/tests -v
```

## Destroy Phase 1

```bash
make plan-destroy
make destroy
```

Review the destroy plan carefully. These commands operate on the dev
environment only.

## Repository layout

```text
architecture/       Architecture description and diagrams
application/        Shared Phase 2A Python Lambda application and tests
dr-orchestrator/    Future event-driven DR automation
gamedays/           Future scenarios and runner
observability/      Future dashboards and alarms
scripts/            Project utility scripts
docs/runbooks/      Operational runbooks
docs/adr/           Architecture decision records
terraform/modules/  Reusable Terraform modules
terraform/environments/dev/  Cost-conscious dev composition
terraform/global/   Future global resources such as DNS
```
