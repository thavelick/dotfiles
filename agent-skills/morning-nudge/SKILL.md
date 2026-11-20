---
name: morning-nudge
description: Pick the one thing to work on today in this project, from the goals in scratch/GOALS.md, then start it on the user's "go". Use for the scheduled weekday morning run, or when asked for the morning nudge or what to work on today.
---

Suggest exactly one thing to do today, then wait. Never offer a runner-up or
a list.

## 1. Goals

Read `scratch/GOALS.md`, relative to the project's main worktree (not a
linked worktree you may be running in). If it is missing, ask the user what
their goals are (front burner and back burner), write their answer there, and
continue.

## 2. Candidates

Gather what is open in this project, then judge from the goal prose which
items relate to a goal:

- Tickets: `gh issue list --state open --limit 200 --json number,title,labels,body,url`.
  A ticket labelled `agent-queue` is ready for an agent; any other ticket
  needs a grilling before an agent can take it.
- PRs: `gh pr list --state open --json number,title,isDraft,reviewDecision,statusCheckRollup,headRefName,url`.
- T3 threads: open (unsettled) top-level threads in this project, snoozed or
  ready. List with `t3_thread_list` and `includeSubagents: false`, both
  `snoozed: true` and the default listing, and page until threads are older
  than a week; an orchestration's subagent threads otherwise crowd out the
  rest. Also run `t3_thread_search` with a few keywords from each goal. Read
  a thread with `t3_thread_read` when its title doesn't say enough. Skip this
  thread and earlier morning-nudge threads.

A ticket that already has an open thread working on it is that thread, not
the ticket: pick the thread so the work continues there instead of starting
over beside it.

## 3. Pick one

Use judgement, not a fixed order:

- Anything tied to a goal beats anything that isn't; the front burner beats
  the back burner.
- Prefer what gets work live and across the line (a PR near merge, a thread
  one step from done) over nudging something far from done.
- Use the ticket's substance and the goal, not the project Priority field, to
  judge importance.

Repeating yesterday's pick is fine when it is still the best one.

## 4. Suggest

Reply with the pick, a link (a thread's `link` verbatim, or the issue/PR
URL), one line on why it beats the rest, and what "go" will start. Then stop.
