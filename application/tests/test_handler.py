import importlib
import json
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import patch


SRC_DIR = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC_DIR))


class HandlerTests(unittest.TestCase):
    def setUp(self):
        self.environment = patch.dict(
            os.environ,
            {
                "SERVICE_NAME": "dr-gameday-api",
                "SERVICE_VERSION": "1.0.0",
                "DEPLOYMENT_ROLE": "PRIMARY",
                "DEPLOYMENT_REGION": "us-east-1",
            },
            clear=True,
        )
        self.environment.start()
        sys.modules.pop("handler", None)
        self.handler = importlib.import_module("handler")

    def tearDown(self):
        self.environment.stop()
        sys.modules.pop("handler", None)

    def invoke(self, path):
        response = self.handler.lambda_handler(
            {
                "rawPath": path,
                "requestContext": {"http": {"method": "GET"}},
            },
            None,
        )
        return response["statusCode"], json.loads(response["body"])

    def test_health(self):
        status_code, body = self.invoke("/health")
        self.assertEqual(status_code, 200)
        self.assertEqual(
            body,
            {
                "service": "dr-gameday-api",
                "status": "healthy",
                "region": "us-east-1",
            },
        )

    def test_status(self):
        status_code, body = self.invoke("/status")
        self.assertEqual(status_code, 200)
        self.assertEqual(body["role"], "PRIMARY")
        self.assertEqual(body["version"], "1.0.0")

    def test_version(self):
        status_code, body = self.invoke("/version")
        self.assertEqual(status_code, 200)
        self.assertEqual(body["version"], "1.0.0")

    def test_dependencies(self):
        status_code, body = self.invoke("/dependencies")
        self.assertEqual(status_code, 200)
        self.assertEqual(body["database"], {"status": "not_configured"})

    def test_unknown_route(self):
        status_code, body = self.invoke("/unknown")
        self.assertEqual(status_code, 404)
        self.assertEqual(body["error"], "not_found")

    def test_runtime_region_takes_precedence(self):
        with patch.dict(os.environ, {"AWS_REGION": "us-west-2"}):
            _, body = self.invoke("/health")
        self.assertEqual(body["region"], "us-west-2")


if __name__ == "__main__":
    unittest.main()
