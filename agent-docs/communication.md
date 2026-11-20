# Communicating with the user

These patterns apply to chat replies, to documents you commit, and to the
questions in [question-format.md](question-format.md). A project's `CLAUDE.md`
can extend them to its tickets, PRs and comments.

## Replies

The user sees only your reply, not your tool output, so restate what a command
or agent returned. Report a gate (typecheck, lint, tests, CI) only when it
failed, flaked or did not run.

Answer a question that turns on an external fact, such as a regulation or a
vendor's behaviour, from the primary source: fetch it, cite it, and say where
it is silent.

## Ticket and PR references

Link every ticket or PR you mention. Make the link text its number, then a few
words that say what it is, or its title when the title already says that. A
bare `#412` makes the user look the ticket up, and words without the number
hide which ticket it is.

- Ticket: `[#412 one-time sign-in code](https://github.com/owner/repo/issues/412)`
- PR: `[#530 state picker](https://github.com/owner/repo/pull/530)`

The exceptions are places where GitHub reads the number itself: `Closes #412`
in a PR body, and a `Blocked by: #412` line.

## Committed documents

Before you commit a new or edited document, run the skill that matches its
reader. Use `/unslop-prose` when a person reads it, and
`/pocock-writing-for-agents` when an agent does: a skill, `CLAUDE.md`, or a
doc an agent reaches through a pointer.

Add a line to an agent doc only when it changes what an agent does, and name
that change before you write it. Leave out a rule that a script already
enforces.
