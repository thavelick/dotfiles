#!/usr/bin/env python3
"""Deny opening or retargeting a PR onto a branch other than the default.

Registered as a PreToolUse hook on Bash. A PR based on another PR's branch
closes unmerged when that branch is deleted on merge; `gh stack` retargets
and rebases the layers above instead, so stacks must go through it.

Catches `gh pr create` / `gh pr edit` with --base, -B, --base=, -Bx, a
`gh pr create` that would pick up a `gh-merge-base` git config, and
`gh api` writes to /pulls with a base= field or a GraphQL baseRefName.

Tokenizes with shlex, so a flag inside a quoted --body or commit message is
one argument and never matches; heredoc bodies are dropped before lexing.
A command shlex can't parse (unbalanced quotes) is let through.

The default branch is assumed to be main or master; any other base costs one
`gh repo view` call to check, so only the rare non-main base pays for it.
"""

import json
import re
import shlex
import subprocess
import sys

DENY_REASON = (
    "A PR based on a non-default branch must be a gh stack stack (hand-built "
    "stacks close unmerged when the parent merges). Add the branch with "
    "`gh stack add <branch>`, then run `gh stack submit --auto` to create its "
    "PR on the parent; set title/body after with `gh pr edit` (no --base)."
)
CHEAP_DEFAULTS = {"main", "master"}
SEPARATORS = {";", "&&", "||", "|", "&", "(", ")", "\n", "|&", ";;"}
# Flags whose next token is a value, so the value is never read as a flag.
PR_VALUE_FLAGS = {
    "-b", "--body", "-F", "--body-file", "-t", "--title", "-H", "--head",
    "-R", "--repo", "-a", "--assignee", "-l", "--label", "-m", "--milestone",
    "-p", "--project", "-r", "--reviewer", "-T", "--template",
    "--add-assignee", "--add-label", "--add-project", "--add-reviewer",
    "--remove-assignee", "--remove-label", "--remove-project",
    "--remove-reviewer", "--attach",
}
API_FIELD_FLAGS = {"-f", "--raw-field", "-F", "--field"}
API_VALUE_FLAGS = API_FIELD_FLAGS | {
    "-H", "--header", "-X", "--method", "-q", "--jq", "-t", "--template",
    "--input", "--hostname", "-p", "--preview", "--cache",
}
# `<<EOF`, `<<-'EOF'` or `<<"EOF"`, then everything up to a line that is
# just that word.
HEREDOC = re.compile(r"<<-?\s*(['\"]?)(\w+)\1[^\n]*\n.*?^\s*\2\s*$", re.S | re.M)
# `pulls` as the last path segment, or `pulls/` and a number.
PULLS_PATH = re.compile(r"/pulls(/\d+)?/?$")
# `baseRefName`, optional spaces, a colon, then a double-quoted branch name.
GRAPHQL_BASE = re.compile(r'baseRefName\s*:\s*"([^"]+)"')


def segments(command):
    lexer = shlex.shlex(HEREDOC.sub("", command), posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    lexer.commenters = ""
    segment = []
    for token in lexer:
        if token in SEPARATORS:
            if segment:
                yield segment
            segment = []
        else:
            segment.append(token)
    if segment:
        yield segment


def gh_args(segment):
    """Args after `gh` in a segment, or None if it doesn't run gh."""
    for i, token in enumerate(segment):
        if token == "gh" or token.endswith("/gh"):
            return segment[i + 1:]
    return None


def flag_value(args, i, long_flag, short_flag):
    """(value, tokens consumed) when args[i] sets the given flag, else None."""
    token = args[i]
    if token in (long_flag, short_flag):
        return (args[i + 1] if i + 1 < len(args) else ""), 2
    if token.startswith(long_flag + "="):
        return token[len(long_flag) + 1:], 1
    if short_flag and token.startswith(short_flag) and not token.startswith("--"):
        return token[len(short_flag):].lstrip("="), 1
    return None


def pr_base(args):
    """Base branch and --repo named by `gh pr create|edit` args."""
    base = repo = None
    i = 0
    while i < len(args):
        base_flag = flag_value(args, i, "--base", "-B")
        repo_flag = flag_value(args, i, "--repo", "-R")
        if base_flag:
            base, step = base_flag
        elif repo_flag:
            repo, step = repo_flag
        elif args[i] in PR_VALUE_FLAGS:
            step = 2
        else:
            step = 1
        i += step
    return base, repo


def api_bases(args):
    """Base branches a `gh api` call would set on a pull request."""
    positional, fields, bases = [], [], []
    i = 0
    while i < len(args):
        token = args[i]
        if token in API_VALUE_FLAGS:
            if token in API_FIELD_FLAGS and i + 1 < len(args):
                fields.append(args[i + 1])
            i += 2
            continue
        attached = re.match(r"(-f|-F|--raw-field=|--field=)(.+)", token)
        if attached:
            fields.append(attached.group(2))
        elif not token.startswith("-"):
            positional.append(token)
        i += 1
    endpoint = positional[0] if positional else ""
    for field in fields:
        key, _, value = field.partition("=")
        if key == "base" and PULLS_PATH.search(endpoint.split("?")[0]):
            bases.append(value)
        elif key == "baseRefName" and endpoint == "graphql":
            bases.append(value)
        elif key == "query" and endpoint == "graphql":
            bases.extend(GRAPHQL_BASE.findall(value))
    return bases


def merge_base_config(cwd):
    """`gh pr create` falls back to branch.<current>.gh-merge-base."""
    def git(*args):
        result = subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True)
        return result.stdout.strip()
    branch = git("branch", "--show-current")
    return git("config", f"branch.{branch}.gh-merge-base") if branch else ""


def default_branch(cwd, repo):
    cmd = ["gh", "repo", "view", "--json", "defaultBranchRef", "-q", ".defaultBranchRef.name"]
    if repo:
        cmd.append(repo)
    try:
        result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=10)
    except (OSError, subprocess.TimeoutExpired):
        return None
    return result.stdout.strip() or None


def is_default(base, cwd, repo):
    return base in CHEAP_DEFAULTS or base == default_branch(cwd, repo)


def violation(command, cwd):
    for segment in segments(command):
        args = gh_args(segment)
        if not args:
            continue
        if args[:2] in (["pr", "create"], ["pr", "edit"]):
            base, repo = pr_base(args[2:])
            if base is None and args[1] == "create":
                base = merge_base_config(cwd) or None
            if base and not is_default(base, cwd, repo):
                return True
        elif args[0] == "api":
            if any(not is_default(b, cwd, None) for b in api_bases(args[1:])):
                return True
    return False


def main():
    payload = json.load(sys.stdin)
    command = payload.get("tool_input", {}).get("command") or ""
    if "gh" not in command:
        return
    try:
        blocked = violation(command, payload.get("cwd") or None)
    except ValueError:
        return
    if blocked:
        print(json.dumps({"hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": DENY_REASON,
        }}))


if __name__ == "__main__":
    main()
