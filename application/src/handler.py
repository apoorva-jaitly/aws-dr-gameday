"""AWS Lambda handler for the regional DR GameDay API."""

import json
import os
from typing import Any


SERVICE_NAME = os.getenv("SERVICE_NAME", "dr-gameday-api")
SERVICE_VERSION = os.getenv("SERVICE_VERSION", "1.0.0")
DEPLOYMENT_ROLE = os.getenv("DEPLOYMENT_ROLE", "UNKNOWN")


def _region() -> str:
    """Prefer the Lambda runtime region, with the explicit app setting as fallback."""
    return os.getenv("AWS_REGION") or os.getenv("DEPLOYMENT_REGION", "unknown")


def _response(status_code: int, body: dict[str, Any]) -> dict[str, Any]:
    return {
        "statusCode": status_code,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body),
    }


def lambda_handler(event: dict[str, Any], _context: Any) -> dict[str, Any]:
    request_context = event.get("requestContext", {})
    http_context = request_context.get("http", {})
    method = http_context.get("method", event.get("httpMethod", ""))
    path = event.get("rawPath", event.get("path", ""))

    if method != "GET":
        return _response(
            404,
            {
                "service": SERVICE_NAME,
                "error": "not_found",
                "path": path,
            },
        )

    common = {
        "service": SERVICE_NAME,
        "region": _region(),
    }

    if path == "/health":
        return _response(200, {**common, "status": "healthy"})

    if path == "/status":
        return _response(
            200,
            {
                **common,
                "status": "healthy",
                "role": DEPLOYMENT_ROLE,
                "version": SERVICE_VERSION,
            },
        )

    if path == "/version":
        return _response(200, {**common, "version": SERVICE_VERSION})

    if path == "/dependencies":
        return _response(
            200,
            {
                **common,
                "database": {
                    "status": "not_configured",
                },
            },
        )

    return _response(
        404,
        {
            **common,
            "error": "not_found",
            "path": path,
        },
    )
