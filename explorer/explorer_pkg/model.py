from dataclasses import dataclass
from typing import Any, Dict, List


@dataclass
class EndpointSample:
    url: str
    method: str
    status_code: int
    headers: Dict[str, str]
    body: Any


@dataclass
class EndpointResult:
    endpoint: str
    method: str
    samples: List[EndpointSample]


@dataclass
class CrawlResult:
    base_url: str
    endpoints: List[EndpointResult]
