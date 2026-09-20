# Phase 2A Application

This directory contains the shared Python Lambda implementation deployed
independently to the primary and DR regions. It has no third-party runtime
dependencies and is packaged as a ZIP by Terraform, so Docker is not required.

## Endpoints

- `GET /health`
- `GET /status`
- `GET /version`
- `GET /dependencies`

API Gateway HTTP API v2 events are handled by `src/handler.py`. Configuration
is supplied through `SERVICE_NAME`, `SERVICE_VERSION`, `DEPLOYMENT_ROLE`, and
`DEPLOYMENT_REGION`. The handler prefers the Lambda-provided `AWS_REGION` value
when available.

Run the unit tests without Docker:

```bash
python3 -m unittest discover -s application/tests -v
```
