---
name: self-compact
description: Compact this session's own context on purpose, with a structured state summary, once it is over a size threshold. Safe to call at every seam of a long-running loop; under the threshold it is a one-line no-op. Use at an idle point of an orchestrator session (relay posted, waiting on the user, or right after absorbing a subagent report), never mid-task.
allowed-tools: Bash(~/.claude/bin/self-compact.sh *)
---

Compact this session's context if it has grown past the threshold, carrying
the task state across the compaction in a form the summarizer cannot mangle.

## Process

1. **Measure.** Run:

   ```bash
   ~/.claude/bin/self-compact.sh check
   ```

   If the output says "nothing to do", reply with that one line and stop.
   If it says the session is not in tmux or the Stop hook is not registered,
   tell the user the context size and stop; nothing can be driven.

2. **Write the state file** at the path the check printed, using the template
   below. This is what survives, so be complete and literal: names, numbers,
   paths, branches, and the real current time in the heading. Do not include
   tool output, gate logs or agent prose. Write it in one go (one Write call
   or one heredoc) so the whole file is visible in the transcript; the
   compaction summarizer reads it from there.

3. **Arm the compaction.** Run:

   ```bash
   ~/.claude/bin/self-compact.sh fire
   ```

4. **End the turn.** Reply with one line ("Self-compacting at N tokens; state
   in <path>.") and do nothing else. When the turn ends, the Stop hook types
   `/compact <instructions>` into this pane, waits for the compaction, then
   sends a prompt telling you to read the state file and continue from its
   Next step.

## State file template

```markdown
# Self-compact state — <ISO timestamp>

## Task
One paragraph: what this session is doing overall and the rules it is
running under (for an orchestrate loop: the skill, the ticket frontier, the
worktree cap, what needs the user's word).

## Per-ticket state
| Ticket | PR | Worktree | Branch | Stage | Agents (name: role) | Awaiting |
| --- | --- | --- | --- | --- | --- | --- |

One row per live work item. Stage is one of: implementing, reviewing,
walkthrough, relayed, merge held, merging, teardown. Awaiting names what the
row is blocked on (a user ruling, an agent report, CI) and any options
already presented to the user, verbatim.

## User rulings
- One bullet per ruling, with the ticket it applies to. Include standing
  rules ("don't ask about merging yet", "batch the relays").

## In-flight agents
| Agent name | Ticket | Asked to | Report expected |
| --- | --- | --- | --- |

Every background agent that has not reported yet. Their later notifications
are meaningless without this table.

## Open questions
- Anything unresolved that the user has not ruled on.

## Next step
The very next action, in one or two sentences.
```

If the session is not an orchestrate loop, keep the headings and adapt the
per-ticket table to whatever the work items are.

## Notes

- `SELF_COMPACT_THRESHOLD` sets the line (default 150000 tokens). It is a
  floor for "compact at the next seam", not a hard stop.
- The state file also stays on disk, so if the summary loses detail the
  resume prompt still points you at the full text.
- Background agents keep running through a compaction and Claude Code
  reminds you which are still running; the In-flight table is what tells you
  which ticket each belongs to.
