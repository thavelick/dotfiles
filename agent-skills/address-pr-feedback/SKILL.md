---
name: address-pr-feedback
description: Review automated PR feedback, discuss with the user, fix what they approve, respond to comments, and push
disable-model-invocation: false
argument-hint: "[pr-number]"
---

Address automated review feedback on PR #$ARGUMENTS.

## Steps

1. **Fetch review comments** using `/pr-comments` first, then supplement with both GitHub API endpoints to ensure full coverage:
   - `gh api repos/{owner}/{repo}/pulls/{pr}/comments` — inline review comments on specific lines
   - `gh api repos/{owner}/{repo}/issues/{pr}/comments` — general conversation comments (where automated review bots like the CI code review post)

   Combine results from all sources, deduplicating and ignoring bot comments that aren't code review feedback (e.g., Vercel deployment status, coverage reports).

2. **Summarize each suggestion** with your assessment of whether it's worth fixing. Present as a numbered table with columns: suggestion, your take (fix/skip + rationale). Be opinionated.

3. **Discuss with the user.** Wait for them to tell you which suggestions to act on and which to skip. They may have additional context or disagree with your assessment.

4. **Implement the agreed fixes.** Make the code changes, run type-check and tests to verify.

5. **Respond to the review comments** on the PR via `gh api repos/{owner}/{repo}/issues/{pr}/comments`. Mention that you're Claude speaking on @thavelick's behalf. Address each numbered suggestion: what was done and why, or why it was skipped.

6. **Commit and push** the changes.
