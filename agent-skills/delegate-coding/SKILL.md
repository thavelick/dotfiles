---
name: delegate-coding
description: For coding/implementation tasks, use your own judgement to delegate the actual code-writing to a subagent running an appropriately lower-power model, to conserve top-tier tokens. Triggers whenever a task is primarily writing or editing code (features, fixes, refactors, mechanical edits). Skip for judgement-heavy work (design, debugging, auditing, synthesis).
---

# Delegate coding to a lower-power subagent

When a task is **primarily writing or editing code**, don't burn top-tier model tokens
on the mechanical work. Use your own judgement to pick an appropriately lower-power model
and run the implementation in a subagent. Keep judgement, review, and synthesis in the
main loop.

**Why:** Implementation work rarely needs the top-tier model. Cost/efficiency — the
expensive model's judgement is better spent on deciding *what* to build and verifying the
result than on typing it out.

## How to apply

1. **Judge the task first.** Ask: is this mostly producing/editing code, or is it
   judgement-heavy?
   - **Delegate** — feature implementation, bug fixes with a clear cause, refactors,
     boilerplate, test writing, mechanical/repetitive edits.
   - **Keep in the main loop** — architecture/design, ambiguous debugging, security or
     code review, data synthesis, anything where the hard part is *deciding* not *typing*.

2. **Pick the model by weight** (your judgement, not a fixed rule):
   - `sonnet` — substantive implementation that still needs real coding ability.
   - `haiku` — trivial, mechanical, or highly-specified edits.

3. **Spawn an Agent** with the model override and a **self-contained prompt**: include the
   files, the exact change, constraints, and how to verify. The subagent doesn't share your
   context, so give it everything it needs.

   ```
   Agent(subagent_type: "general-purpose", model: "sonnet",
         description: "...", prompt: "<self-contained task + files + verify steps>")
   ```

4. **Review in the main loop.** Read the subagent's result, sanity-check it, run/verify as
   needed, and only then commit. You own correctness, not the subagent.

## When to skip

If the task is small enough that delegating (writing a self-contained prompt, spawning,
reviewing) costs more than just doing it, do it inline. Judgement over ceremony.
