---
name: grill-with-collaboration
description: Grill the user about a plan, design, or decision with a shared collaboration doc as the agenda. Use when the user asks to grill something and also wants a doc, an agenda, shared notes, or a scratchpad to run it in.
---

Run a `/grilling` session with a `/collaboration` doc as the agenda. The doc
carries the breadth — every open question, every decision made so far — so the
chat can stay narrow and the record survives the scroll.

## 1. Open the doc, seeded with the template

Do this first, before asking anything:

```bash
~/.claude/skills/collaboration/collab.sh --template ~/.claude/skills/grill-with-collaboration/template.md
```

The template only seeds a doc that does not exist yet; a re-run after a resume
finds the grilling already in progress and leaves it alone.

`example.md` in this directory is a filled-in doc from a real session. Read it
before you write — it sets the level of brevity. Decisions are a few lines, not
essays.

## 2. Fill the top of the doc before the first question

Replace `<subject>` in the title, then write `## Context`: what this grilling is
about, and — as a bulleted list — what is already settled and not up for
re-deciding. If the user has not looked at the material in a while, this is the
context dump they need, and it belongs in the doc rather than in chat where it
scrolls away.

Then write the whole opening frontier into `## Questions` as an unchecked
checklist, one line each, before asking anything:

```markdown
- [ ] Q1 Mechanism — a script, a SQL paste, or an app screen?
```

## 3. The rhythm

Ask in chat, record in the doc. After every answer, before the next question:

- Tick the question's box `[x]`.
- Append the decision under `## Decisions` as `- **Q1** <the decision, and the
  one thing that made it the answer>`.
- Add any questions the answer unblocked to `## Questions`, still unchecked.

Say in one line what you wrote. `## Notes` holds scenarios, tangents, and things
noticed that are not decisions.

Follow `/grilling` for everything else — question format, round sizing, and the
rule that finding facts is your job, not the user's.

## 4. When the frontier is empty

The doc is now the record of the session. It lives in `/tmp`, so offer to copy
it into the repo if the decisions matter beyond today.
