#!/usr/bin/env python3
"""Gated sound effects for Claude Code hooks.

Subcommands:
  start                       Record turn start time (UserPromptSubmit hook).
  play <sound> <threshold>    Play `sfx <sound>` if elapsed >= threshold seconds.
"""
import json
import subprocess
import sys
import time
from pathlib import Path


def timestamp_path(session_id: str) -> Path:
    return Path(f"/tmp/claude_prompt_time_{session_id}")


def read_session_id() -> str:
    return json.load(sys.stdin)["session_id"]


def cmd_start() -> None:
    timestamp_path(read_session_id()).write_text(str(int(time.time())))


def cmd_play(sound: str, threshold: int) -> None:
    path = timestamp_path(read_session_id())
    try:
        start = int(path.read_text().strip())
    except (FileNotFoundError, ValueError):
        return
    if int(time.time()) - start >= threshold:
        subprocess.run(["sfx", sound], check=False)


def main() -> None:
    args = sys.argv[1:]
    if args == ["start"]:
        cmd_start()
    elif len(args) == 3 and args[0] == "play":
        cmd_play(args[1], int(args[2]))
    else:
        print(__doc__, file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        # Never let a hook failure block Claude, but surface what broke.
        print(f"claude-notify-sfx: {type(e).__name__}: {e}", file=sys.stderr)
        sys.exit(0)
