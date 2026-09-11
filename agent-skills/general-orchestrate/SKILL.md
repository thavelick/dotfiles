---
name: general-orchestrate
description: Orchestrate agents through work you hand it — brief an implementor in its own worktree, prep the PR for human review, relay what came back, and merge on the user's word.
argument-hint: "[ticket or PR numbers, or instructions on what to do]"
disable-model-invocation: true
---

`$ARGUMENTS` says what to orchestrate and where to start: ticket or PR
numbers, or instructions in prose, such as what to skip, which step to pick
up at, or what to do with the result. With no arguments, ask the user what
to work on — there is no default.

You are the orchestrator: you brief agents, relay their reports, and hold the
merge for the user. Agents implement and review. Edit directly only when it
costs fewer tokens than a brief.

## Models

| Role                                    | Model |
| --------------------------------------- | ----- |
| Implementor running `/pocock-implement` | opus  |
| Code review the implementor agent runs  | fable |
| `/meat` runner                          | opus  |
| `/walkthrough` runner                   | opus  |
| Briefed fix agents                      | opus  |

Anything else is your judgement.

## Worktrees

Not all repos are set up to use worktrees effectively. Use your judgement on
whether parallel work is suitable and whether the repo has guidance around
worktrees.

## Steps

1. **Pick.** What `$ARGUMENTS` names. One item per implementor, at most
   three worktrees live at once.
2. **Implement.** Spawn the implementor to invoke `/pocock-implement <n>`.
   The brief: branch `<feature>_<n>` cut from the default branch in its own
   worktree, set up the way this repo sets worktrees up, its review agents on
   fable, every gate this repo gates a PR on run inside that worktree —
   typecheck, lint, tests with coverage, and the end-to-end suite when the
   change touches it — a PR against the default branch, the worktree and its
   stack left up, nothing merged. It reports the PR number, worktree path and
   branch, files changed, and the gate output verbatim.
   Done when the PR is open and every gate passed in its worktree.
3. **Prep for human review.** Two jobs, in parallel.
   - **Reading diff.** Size it by the additions in `gh pr diff <pr> --stat`,
     since deleted code skims easily. Over about 200 lines added,
     `/meat <pr>`. Under that, no `/meat` run is needed: it keeps most of a
     small diff, and the run costs more than it cuts.
   - **Walkthrough**, when a visual element changed. `/walkthrough` pointed
     at the app the worktree is serving, at whatever address this repo gives
     it. Its runner is the only agent holding the browser.

   Done when the reading diff, and the walkthrough if shot, are in hand.

4. **Relay.** The reading diff, the walkthrough and its oddities, and anything
   the implementor's code review left open. Lay out options with real costs
   and recommend one. A fix agent gets a brief naming the decided change, the
   files, and the gates. The merge is the user's call; everything else
   proceeds without asking.
5. **Merge** on the user's word with `/merge`. Then tear down: stop whatever
   the worktree was running and undo its setup the way this repo undoes it;
   from the main checkout `git worktree remove --force <path>`
   (`git worktree unlock` first if locked), `git worktree prune`,
   `git branch -D <branch>`, `git pull --ff-only`. Stop the item's idle
   agents (implementor, reviewer, walkthrough runner) so they do not linger
   with the worktree gone.

## Constraints the environment does not state

- CI notifies on completion; carry on with other work instead of watching it.
- The user sees only your reply, so restate what agents and commands returned.
