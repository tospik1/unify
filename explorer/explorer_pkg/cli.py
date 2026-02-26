import argparse
import json
from typing import Dict, Tuple

from .crawler import Crawler
from .http_client import HttpClient
from .model import CrawlResult


def parse_headers(values: list[str]) -> Dict[str, str]:
    headers: Dict[str, str] = {}
    for v in values:
        key, _, value = v.partition(":")
        headers[key.strip()] = value.strip()
    return headers


def parse_basic_auth(value: str) -> Tuple[str, str]:
    user, _, password = value.partition(":")
    return user, password


def main() -> None:
    parser = argparse.ArgumentParser(description="Integrator API Explorer")

    parser.add_argument("base_url")
    parser.add_argument("--max-endpoints", type=int, default=10)
    parser.add_argument("--retries", type=int, default=2)
    parser.add_argument("--timeout", type=float, default=5.0)
    parser.add_argument("--methods", default="GET")
    parser.add_argument("--header", action="append", default=[])
    parser.add_argument("--basic-auth")
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument("--output")

    args = parser.parse_args()

    headers = parse_headers(args.header)
    basic_auth = parse_basic_auth(args.basic_auth) if args.basic_auth else None

    client = HttpClient(
        timeout=args.timeout,
        retries=args.retries,
        headers=headers,
        basic_auth=basic_auth,
    )

    crawler = Crawler(
        base_url=args.base_url,
        methods=[m.strip().upper() for m in args.methods.split(",")],
        max_endpoints=args.max_endpoints,
        client=client,
        verbose=args.verbose,
    )

    result = CrawlResult(
        base_url=args.base_url,
        endpoints=crawler.crawl(),
    )

    output = json.dumps(result, default=lambda o: o.__dict__, indent=2)

    if args.output:
        with open(args.output, "w") as f:
            f.write(output)
    else:
        print(output)
