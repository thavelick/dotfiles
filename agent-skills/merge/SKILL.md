---
name: merge
description: Merge the current PR with branch deletion, but only after CI passes. Use when the user clearly means "merge the open PR" (e.g. plain "merge", "merge it", "ship it"). Do NOT use for git branch merges ("merge main into X") or code merges.
---

First, confirm intent. Only proceed with this skill if it's obvious the user means "merge the current open PR." If they mean a git branch merge (e.g. "merge main into our branch") or a code merge (combining functions, files, etc.), stop and handle what they actually asked for instead.

If a PR merge is intended, follow these steps:

1. Get the current PR number using `gh pr view --json number -q .number`

2. Wait for CI to finish using `gh pr checks <number> --watch > /dev/null && gh pr checks <number>` — the first call blocks until checks complete (discarding its noisy per-refresh output), and the second produces one clean final-state block. Use a generous timeout on the Bash call.

3. Based on the final result:
   - **If all checks passed**: Proceed to merge immediately
   - **If any check failed**: Notify the user that CI failed and abort without merging

4. If CI passed: Execute `gh pr merge --merge --delete-branch` to merge with a merge commit and delete both local and remote branches

5. Report the final status to the user
