Merge the current PR with branch deletion, but only after CI passes.

Follow these steps:

1. Get the current PR number using `gh pr view --json number -q .number`

2. Check the CI status using `gh pr checks --json state,bucket -q '.[] | select(.required == true) | {state: .state, bucket: .bucket}'`

3. Based on the CI status:
   - **If all required checks are passing (bucket: "pass")**: Proceed to merge immediately
   - **If any checks are pending (bucket: "pending")**: Poll every 10 seconds with `sleep 10 && gh pr checks` until no longer pending, reporting progress to the user (e.g., "CI still running, checking again in 10 seconds..."). Once no longer pending, check if passed or failed.
   - **If any checks failed (bucket: "fail")**: Notify the user that CI failed and abort without merging

4. If CI passed: Execute `gh pr merge --merge --delete-branch` to merge with a merge commit and delete both local and remote branches

5. Report the final status to the user
