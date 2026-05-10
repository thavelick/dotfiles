---
name: dev-workflow
description: Start working on a ticket, dev workflow, work on an issue, pick up a ticket
disable-model-invocation: false
argument-hint: "[issue-number-or-description]"
---

Run the full developer workflow end-to-end: pick a ticket, branch, plan, implement, commit, simplify, PR, wait for CI, and address feedback. Execute each step sequentially, waiting for completion before moving to the next.

## Steps

1. **Ticket selection**:
   - If `$ARGUMENTS` is provided, treat it as an issue number or description.
   - Otherwise, run `gh issue list --assignee @me --limit 10` to show issues assigned to the user.
   - If no issues are found assigned to the user, fall back to `gh issue list --limit 10`.
   - Present the list and ask the user to pick one.

2. **Ticket creation** (if no existing ticket matches):
   - Draft the ticket body and write it to a temporary file (e.g., `/tmp/issue-draft.md`).
   - Propose all attributes, including project fields, and ask the user to review the body file and confirm the attributes before running any creation command.
   - Only after explicit approval, run `gh issue create` with the approved values.

3. **Branch creation**: Invoke the `cut-branch` skill with the issue number.

4. **Planning**: Invoke `EnterPlanMode` (the built-in `/plan` command). Present a plan for implementing the ticket. Wait for the user to approve the plan before continuing.

5. **Implementation**: Execute the approved plan. Build the feature or fix step-by-step.

6. **Visual/functional verification** (conditional): If the implementation touched UI components, styles, layouts, or templates, spawn a Playwright subagent to verify the feature works as intended. The agent should use its best judgment on verification method (screenshots, checking DOM elements, verifying text content, testing interactions, etc.). If verification passes, proceed without waiting for approval. If it fails, fix the issue before continuing.

7. **Initial commit**: Invoke the `commit-commands:commit` skill.

8. **Simplify**: Invoke the `simplify-agent` skill on the changed code. This step is for pre-PR cleanup — refactoring to cleaner code, removing duplication, improving reuse. It is NOT for addressing PR review feedback (that's step 11). The `simplify-agent` skill launches code-simplifier agents that review for reuse, quality, and efficiency issues, then fix what they find.

9. **Push & PR**: Invoke the `commit-commands:commit-push-pr` skill.

10. **Wait for CI**: Spawn a background agent that watches `gh pr checks` until all checks complete, then reports pass/fail. Continue to the next step only after the background agent completes.

11. **Address feedback**: Invoke the `address-pr-feedback` skill with the PR number. This handles automated review bot feedback and human reviewer comments — different from the simplify step which is a pre-PR self-review.

12. **Final review**: Ask the user if they have further feedback on the PR. If so, address it. If not, the workflow is complete.
