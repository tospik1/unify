import requests
from typing import Dict, Optional, Tuple


class HttpClient:
    def __init__(
        self,
        timeout: float,
        retries: int,
        headers: Dict[str, str] | None = None,
        basic_auth: Tuple[str, str] | None = None,
    ):
        self.timeout = timeout
        self.retries = retries
        self.headers = headers or {}
        self.basic_auth = basic_auth

    def request(self, method: str, url: str) -> Optional[requests.Response]:
        for _ in range(self.retries):
            try:
                return requests.request(
                    method=method,
                    url=url,
                    timeout=self.timeout,
                    headers=self.headers,
                    auth=self.basic_auth,
                )
            except requests.RequestException:
                continue
        return None
