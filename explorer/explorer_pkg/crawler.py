from typing import List

from .model import EndpointResult, EndpointSample
from .http_client import HttpClient
from .extractor import extract_body
from .discovery import discover_paths


class Crawler:
    def __init__(
        self,
        base_url: str,
        methods: List[str],
        max_endpoints: int,
        client: HttpClient,
        verbose: bool = False,
    ):
        self.base_url = base_url
        self.methods = methods
        self.max_endpoints = max_endpoints
        self.client = client
        self.verbose = verbose

    def crawl(self) -> List[EndpointResult]:
        results: List[EndpointResult] = []
        paths = discover_paths(self.base_url, self.max_endpoints)

        for url in paths:
            for method in self.methods:
                if self.verbose:
                    print(f"[crawl] {method} {url}")

                response = self.client.request(method, url)
                if response is None:
                    continue

                sample = EndpointSample(
                    url=url,
                    method=method,
                    status_code=response.status_code,
                    headers=dict(response.headers),
                    body=extract_body(response),
                )

                results.append(
                    EndpointResult(
                        endpoint=url,
                        method=method,
                        samples=[sample],
                    )
                )

        return results
