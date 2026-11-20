# Design tree

`/grilling` builds a design tree before it asks the user anything.
This doc says how to build it and how to sort its leaves.

## The tree

A **design tree** maps a plan as decisions: every decision branches into the
decisions that hang off it. The **frontier** is every decision whose
prerequisites are settled, the questions you can ask now without guessing at
answers you have not heard.

The tree is built when each leaf is one of these:

- a **cited fact**
- a **blocked fact**: a bullet opening **Cannot settle from here**, with what
  would settle it: the missing command, the sandbox probe, or the action only
  the user can take
- a **shape line**: what the change does where no credible alternative exists
- a **tagged question**

## Facts

A **fact** is anything the repo, the vendor docs or a command can answer.
Finding facts is the agent's job, never the user's. Settle each one and cite
it: a doc path, an ADR number, a type or function name, or the command run and
what it printed. Run only commands that complete without a credential prompt.
A consequence of two cited facts is a fact citing both.

## Decisions

A **decision** is one that two reasonable people would answer differently
with the same facts. Write the second option. When no credible one exists,
the leaf is a shape line. When the only way to settle a leaf is to choose, it
is a decision even when the choice looks obvious.

Write each decision in the format in [question-format.md](question-format.md).
The clause of why names what the losing options cost, so it holds for the
pick alone. A decision with no recommendable answer is a fact still unfound;
go find it.

When the work is large enough to span several PRs, how it splits into PRs is
a decision on the tree.

## Sorting

Tag every question after its title: `❓ **Q2** - **<title>** (fork, one-way):`.
The tag says when the user answers it.

A **load-bearing** question is answered before the work starts. Give it each
tag that applies:

- **fork**: its answer makes another question irrelevant, or changes that
  question's options.
- **one-way**: a switch to another option after the work is built changes a
  lot, for example stored data, a schema, a vendor setup, or code that many
  callers adopt.
- **policy**: only the user can decide it, whatever it costs to reverse. That
  is spend, a credential the user holds, legal meaning, scope against a
  deadline, a contradiction of a recorded decision such as an ADR, or copy
  that changes what end users are told is true.

Every other question is **deferrable**, tagged `(deferrable)`: naming,
ordering, defaults, how the work is bundled into PRs, tooling that is free,
copy that changes only how a thing is said, which of two equivalent seams to
build on. It goes ahead on the recommendation unless the user overrides it.

A child of an open fork is asked with it, its title ending "(if Q1 is B)".
Grandchildren wait until the fork is answered.
