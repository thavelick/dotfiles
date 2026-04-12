Merge the current PR with branch deletion, but only after CI passes.

Follow these steps:

1. Get the current PR number using `gh pr view --json number -q .number`

2. Wait for CI to finish using `gh pr checks --watch` (this blocks until all checks complete — no manual polling loop needed). Use a generous timeout on the Bash call.

3. Based on the final result:
   - **If all checks passed**: Proceed to merge immediately
   - **If any check failed**: Notify the user that CI failed and abort without merging

4. If CI passed: Execute `gh pr merge --merge --delete-branch` to merge with a merge commit and delete both local and remote branches

5. Report the final status to the user
