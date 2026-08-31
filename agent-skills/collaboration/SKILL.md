---
name: collaboration
description: Work alongside the user in a shared editor pane — a live collaboration doc for your working notes, plus the ability to put any file in front of them at a specific line. Use when the user asks to collaborate, wants a shared doc or scratchpad, or wants to watch and edit your notes in vim as you work — and reach for it yourself when a task (a schema, a plan, a spec, a long grilling) needs a durable artifact you both edit rather than a wall of chat.
---

Share an editor with the user. They see your working notes as you write them and
can annotate in place; you can also pull up any file for them to look at with
you.

## 1. Open the doc

Invoking this skill means opening the doc. Do it first, before anything else:

```bash
~/.claude/skills/collaboration/collab.sh
```

No arguments — one session, one doc, always `collaboration.md` in the session
scratchpad. Add `--focus` only if the user asked to be dropped into the pane; by
default focus stays put so they can keep typing to you.

The script prints `status:`, `doc:`, `created:` and (in tmux) `pane:`:

- `opened` — a new pane is showing the doc.
- `attached` — the editor was already in the window; the doc was loaded into it.
  Expected after `/clear`, which mints a new session and so a new doc.
- `reused` — the doc was already the open buffer. Nothing happened; say so rather
  than claiming you opened something.
- `no-tmux` — no pane was created. Give the user the `open-with:` command, then
  carry on writing to the doc regardless.

The doc is keyed by session id, the editor pane by tmux window, so one editor
serves every doc opened in that window over time. Re-run the script after a
resume; it is idempotent and will reuse, attach, or respawn as needed.

## 2. Show the user a file

```bash
~/.claude/skills/collaboration/collab.sh open FILE [LINE [COL]]
```

Opens `FILE` as a tab in the same editor, with the cursor placed at `LINE`/`COL`
when given — use it for "here is the function I mean", "read this config with
me", "this is the line that breaks". It spawns the editor first if none is up,
and switches to an existing tab (`status: switched-tab`) instead of duplicating
one already open.

`status: unsupported` means no tmux, or an `EDITOR` that is not nvim; pass the
user the `open-with:` command instead.

**Etiquette: at most one new tab per conversational turn.** The pane is the
user's window, not your dumping ground — every tab you add is something they did
not ask to look at. Pick the single most useful file for the point you are
making. Reopening a tab that already exists is free and does not count. If they
ask for several files at once, open several; that is them asking.

Do not close tabs or kill the pane. That is theirs.

## 3. Write to the doc

The pane reloads on its own (autoread plus a repeating `checktime`), so anything
you save appears within a second without the user doing anything.

- **Read before you write.** The user edits this file too. Never regenerate it
  wholesale from memory — re-read it, then make targeted edits so their notes and
  annotations survive.
- **Keep it the artifact, not a transcript.** Settled decisions, the schema, the
  plan, the open questions. Chat belongs in chat.
- **Mark what is unsettled** so the user knows where their input is wanted —
  an `Open questions` section, or `TODO`/`?` markers they can answer in place.
- **Say when you have written.** A one-line "added the R4 tradeoff to the doc"
  keeps them from re-reading the whole file to find the change.

If the user has unsaved edits when you write, their editor warns instead of
silently discarding them — but avoid the collision by reading first and keeping
your writes small and additive.

The doc lives in `/tmp`, so it does not survive a reboot. If its content matters
beyond the session, offer to copy it into the repo.
