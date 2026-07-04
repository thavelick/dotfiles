---
name: ci-review
description: Run the same comprehensive review your CI runs on PRs, but locally against your full local-vs-remote diff and printed as text in the session, with an optional fix loop. Use when the user wants to mirror or preview the CI code review before pushing, get their branch CI-clean, or run an iterative review-then-fix loop. Triggers on "run the CI review locally", "preview the CI review", "mirror CI", "ci review", "will CI pass", "review-and-fix before pushing". For a plain read-only local review with no CI-parity framing or fix loop, prefer /review-local instead.
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git status:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(git remote:*), Bash(git symbolic-ref:*), Bash(git ls-files:*), Read, Grep, Glob, Edit, Write
disable-model-invocation: false
argument-hint: "[--fix]"
---

# Local CI Review

Run the same comprehensive review the CI performs on pull requests, but against
your local changes and printed as text so you can get clean **before** pushing.
The goal is parity: if this comes back clean, the CI review should too.

If `$ARGUMENTS` contains `--fix`, skip the confirmation prompt and go straight
into the fix loop (Step 5) after the first review.

## Step 1: Determine the diff scope

Review everything CI would see if you pushed right now: uncommitted working-tree
changes **plus** commits ahead of the base branch. Work it out with git:

```bash
git rev-parse --abbrev-ref HEAD                              # current branch
# Default branch on origin (fallbacks: main, then master):
git symbolic-ref --quiet refs/remotes/origin/HEAD | sed 's@^refs/remotes/@@'
git status --short                                           # uncommitted changes
```

- Let `BASE` = the origin default branch (e.g. `origin/main`). If
  `refs/remotes/origin/HEAD` is unset, try `origin/main`, then `origin/master`.
  If none resolve (no remote / no upstream), fall back to the local `main` or
  `master`, and if even that is missing, review only `git diff HEAD` plus
  untracked files and note the limitation.
- Compute the merge base so unrelated commits on the base don't pollute the diff:
  `MB=$(git merge-base "$BASE" HEAD)`
- The review diff is everything from the merge base through the working tree:

```bash
git diff "$MB"                    # committed + staged + unstaged tracked changes
git ls-files --others --exclude-standard   # untracked files (read their contents too)
git diff "$MB" --stat            # file/line inventory for the summary
```

If there are no changes at all, report "No local changes to review" and stop.

## Step 2: Honor repo conventions

If the repo has a `CLAUDE.md` (root, and any in directories containing changed
files), read them and treat their rules as review criteria — CI checks out the
repo and honors them implicitly, so mirror that. Keep the skill otherwise
repo-agnostic: make no project-specific assumptions beyond what the diff and any
CLAUDE.md tell you.

## Step 3: Review across the five CI dimensions

Read the diff (and enough surrounding context to judge it) and review across the
same five dimensions the CI prompt uses:

1. **Code Quality** — best practices, error handling, readability
2. **Security** — vulnerabilities, input sanitization, auth logic
3. **Performance** — bottlenecks, inefficient queries, resource issues
4. **Testing** — test coverage, edge cases, missing scenarios
5. **Documentation** — code comments, README updates if needed

Focus on real issues introduced by these changes, not pre-existing problems.
Don't report things a linter, typechecker, or compiler would catch. For large
diffs, prioritize the files most relevant to each dimension.

## Step 4: Report findings as text

Print the review in the conversation (this replaces CI's inline PR comments):

---

### CI Review: `<branch>` vs `<base>` — iteration `<n>`

**Summary**: <1-2 sentences on what the changes do>
**Files**: <count> | **Lines**: <count>

#### Findings (most severe first)

For each finding, one entry with:
- `file_path:line` — **<one-line summary>**
- Concrete failure scenario or rationale (why it bites, when it triggers).
- Dimension tag (Code Quality / Security / Performance / Testing / Documentation).

Order by severity (blocking → suggestion → nit). Omit the section if empty.

#### General observations

Top-level notes that aren't tied to a specific line (architecture, patterns,
overall test strategy) — this mirrors CI's top-level comments. Omit if none.

---

If nothing is found: report "No findings. This should pass CI review." and, if
not in fix mode, stop here.

## Step 5: Fix loop

After presenting findings, if `--fix` was passed, begin fixing immediately.
Otherwise ask: "Want me to fix these?" and wait. If the user declines, stop.

For each iteration:

1. Apply fixes for the agreed findings (edit the files directly).
2. Re-run Steps 1, 3, and 4 on the **updated** diff.
3. **Do not repeat feedback already given in a previous iteration** — this is the
   local equivalent of CI's `track_progress`. Keep a running list of findings
   raised this session. On each re-review, report only:
   - **New or changed** findings introduced since the last pass.
   - A brief **resolution status** of prior findings (Fixed / Still open / Won't fix).
4. Repeat until a pass yields no new findings, or the user stops.

When the loop ends, give a one-line final verdict: clean and ready to push, or
the list of anything intentionally left unaddressed.

## Guidelines

- This is a review that may also fix; outside the fix loop, do not modify files.
- Do not run builds, typecheck, or the app — those run separately in CI.
- Be concise: one to two sentences per finding.
- Never invent findings to look thorough; an empty report is a valid result.
