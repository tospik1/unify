from typing import List
from urllib.parse import urljoin


COMMON_PATHS = [
    "/",
    "/api",
    "/api/v1",
    "/health",
    "/status",
    "/users",
    "/products",
    "/orders",
    "/search",
]


def discover_paths(base_url: str, limit: int) -> List[str]:
    discovered = []

    for path in COMMON_PATHS:
        if len(discovered) >= limit:
            break
        discovered.append(urljoin(base_url.rstrip("/") + "/", path.lstrip("/")))

    return discovered
