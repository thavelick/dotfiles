#!/usr/bin/env python3
"""Poll GitHub status and optionally wait until it recovers."""

import argparse
import json
import signal
import sys
import time
import urllib.request
import urllib.error
from datetime import datetime

URL = "https://www.githubstatus.com/api/v2/summary.json"

SEVERITY = ["none", "minor", "major", "critical"]

COMPONENT_SYMBOLS = {
    "operational": ("\033[32m", "●"),  # green
    "degraded_performance": ("\033[33m", "▲"),  # yellow
    "partial_outage": ("\033[31m", "◐"),  # red
    "major_outage": ("\033[91m", "✖"),  # bright red
}

RESET = "\033[0m"


def fetch_summary():
    req = urllib.request.Request(URL, headers={"User-Agent": "ghstatus/1.0"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read())


def print_status(data):
    now = datetime.now().strftime("%H:%M:%S")
    indicator = data["status"]["indicator"]
    description = data["status"]["description"]

    color = {
        "none": "\033[32m",
        "minor": "\033[33m",
        "major": "\033[38;5;208m",
        "critical": "\033[91m",
    }.get(indicator, "")

    print(f"[{now}] {color}{description}{RESET}")

    for comp in data["components"]:
        # skip the overall "GitHub" page-level component
        if comp.get("group") is False and comp["name"] == "GitHub":
            continue
        status = comp["status"]
        sym_color, symbol = COMPONENT_SYMBOLS.get(status, ("", "?"))
        print(f"  {sym_color}{symbol}{RESET} {comp['name']}: {status}")

    print()


def within_max_severity(indicator, max_severity):
    return SEVERITY.index(indicator) <= SEVERITY.index(max_severity)


def main():
    parser = argparse.ArgumentParser(description="Poll GitHub status")
    parser.add_argument(
        "-i",
        "--interval",
        type=float,
        default=5,
        help="Poll interval in minutes (default: 5)",
    )
    parser.add_argument(
        "-s",
        "--max-severity",
        choices=SEVERITY,
        default="minor",
        help="Max acceptable severity (default: minor)",
    )
    parser.add_argument(
        "-1",
        "--once",
        action="store_true",
        help="Check once and exit",
    )
    args = parser.parse_args()

    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))

    while True:
        try:
            data = fetch_summary()
        except (urllib.error.URLError, OSError, json.JSONDecodeError) as e:
            print(f"Error fetching status: {e}", file=sys.stderr)
            if args.once:
                sys.exit(2)
            time.sleep(args.interval * 60)
            continue

        print_status(data)
        indicator = data["status"]["indicator"]

        if within_max_severity(indicator, args.max_severity):
            sys.exit(0)

        if args.once:
            sys.exit(1)

        time.sleep(args.interval * 60)


if __name__ == "__main__":
    main()
