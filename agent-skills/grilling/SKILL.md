---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

A long grilling, or one whose decisions have to outlive the chat, belongs in `grill-with-collaboration` — the open questions and the settled decisions go into a doc you both edit instead of scrolling away.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet. Each round costs the user one reply, so fill it with as many frontier questions as they can answer without holding two tradeoffs in mind at once — one question if it needs weighing, up to five if each is a pick from named options. Number each question and give your recommended answer, then one clause of why. Wait for the user's answers before the next round.

Complexity is a property of the decision, not a dial you turn. Never inflate a pick into a deliberation to justify a smaller round.

Each question should be formatted like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <the pick, then one clause of why>
```

Write each question to these rules:

- **One decision per question.** Split compound questions.
- **State options in parallel form**: identical phrasing except the dimension that differs. No incidental variation.
- **One option per line**, as its own list item. Options run together in a paragraph are read as one blur.
- **Put the discriminating detail at the end** of the sentence.
- **No forward references.** Each question must stand alone.
- **Cut hedges** — "probably", "it depends", "we could consider". If it depends, say what it depends on; that's the real question.

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it — don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report — ask the rest of the frontier now. The _decisions_ are the user's — put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
