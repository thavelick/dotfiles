---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding.

A long grilling, or one whose decisions have to outlive the chat, belongs in `grill-with-collaboration`: the open questions and the settled decisions go into a doc you both edit instead of scrolling away.

## Build the tree first

Before round 1, build the whole **design tree** and tag every question on it, as `~/.claude/agent-docs/design-tree.md` says. You cannot tell a fork until you see what hangs off it. If the subject has a ticket, read it with its comments first; settled answers there are leaves, not questions.

Write every question in the format in `~/.claude/agent-docs/question-format.md`.

## Rounds

Work the tree in **rounds**. Each round costs the user one reply, so fill it with as many frontier questions as they can answer without holding two tradeoffs in mind at once: one question if it needs weighing, up to five if each is a pick from named options. Wait for the user's answers before the next round. Rounds go in this order:

1. **Forks.** While the frontier holds a fork, the round asks forks. A fork's answer can remove questions, so settle it before the user weighs anything it might remove.
2. **One-way and policy.** With no fork on the frontier, the round asks the one-way and policy questions.
3. **Deferrable.** A deferrable question never holds up a round. Treat your recommendation as its answer so the tree grows past it. When the frontier holds only deferrable questions, say so and show all of them in one list. The user replies "take your picks" or overrides any by number.

Complexity is a property of the decision, not a dial you turn. Never inflate a pick into a deliberation to justify a smaller round.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier, tag the new questions, and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

When an answer opens a branch that needs a new fact, dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report. Ask the rest of the frontier now. The load-bearing _decisions_ are the user's: put each to them and wait. A deferrable one goes to them once, in the closing list.

## Done

The session is done when the frontier is empty and the user has answered the deferrable list: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
