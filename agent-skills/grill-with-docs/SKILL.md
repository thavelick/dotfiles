---
name: grill-with-docs
description: Docs-aware grilling. Explores the repo's existing docs first, then interviews the user relentlessly about a plan or design while cross-referencing those docs and the code. Use when user wants to stress-test a plan against the project's existing documentation, says "grill me with docs", "grill against the docs", or similar.
---

Interview the user relentlessly about every aspect of the plan until shared understanding is reached. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, recommend an answer.

## Question delivery

Ask one question at a time via the `AskUserQuestion` tool. List the recommended option first and append " (Recommended)" to its label. Wait for the answer before moving on.

If a question can be answered by reading the codebase, read the codebase instead of asking.

## Step 1 — Discover docs (once, up front)

Before the first question, launch a single `Explore` subagent to find docs relevant to the topic being grilled. Tell it to look at:

- `README.md`, `CLAUDE.md`, `AGENTS.md` at the repo root if present
- Everything in `docs/` (list it, then read files whose names look topically relevant)
- Any other top-level `.md` whose name looks relevant to the topic

Ask Explore to return concrete excerpts with file paths, not summaries. Don't assume any particular doc structure — every repo is different, and many will have very little. If discovery comes back near-empty, proceed without docs; don't propose creating any.

## Step 2 — Grill, using the docs

- **Surface conflicts.** If the user's claim contradicts a discovered doc, call it out by file: "Your `docs/E2E.md` says X — you just said Y, which is it?"
- **Sharpen terms only if the docs already did.** Don't invent canonical terminology; only push for precision when an existing doc establishes it.
- **Cross-reference code.** When the user states how something works, verify against the code before accepting it.
- **Probe edge cases with concrete scenarios** to force precision on boundaries.

## Step 3 — Artifact at end of session

- **If plan mode is active** (you'll know from system reminders / having entered via `EnterPlanMode`): the active plan file is the artifact. Fold resolved decisions into it through the normal plan-mode flow before calling `ExitPlanMode`.
- **Otherwise**: ask the user via `AskUserQuestion` whether to (a) write a new standalone notes file at a path they pick, (b) open a GitHub issue capturing the resolved decisions, or (c) do nothing.
