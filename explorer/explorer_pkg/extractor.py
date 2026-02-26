import json
from typing import Any, Optional
import requests


def extract_body(response: requests.Response) -> Optional[Any]:
    content_type = response.headers.get("Content-Type", "")

    if "application/json" in content_type:
        try:
            return response.json()
        except json.JSONDecodeError:
            return None

    return None
