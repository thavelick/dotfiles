---
name: meat
description: Abridge a diff into a "reading diff" — drop mechanical noise, keep what carries meaning. Use when the user wants to read/review a large diff, PR, or commit at the concept level rather than line by line.
disable-model-invocation: false
argument-hint: "[pr-number | revision | range | -w | -staged]"
---

Abridge `$ARGUMENTS` into a reading diff.

You are the model in meat's agent loop. `meatx` does the deterministic halves —
prompt assembly and plan compilation — and you supply the judgment in between.
You never write the output diff: you write an **edit plan** of coordinates, and
`meatx apply` applies it to the original. That is the whole point, so do not
hand-write diff text at any stage.

A bare integer argument is a PR number. Anything else is passed to git as a
revision, a range, or one of `-w` / `-staged`.

If `meatx` is not on `$PATH`, stop and follow [INSTALL.md](INSTALL.md) — it also
covers rebuilding after a fork change and rebasing onto upstream.

## 1. Prepare

Pick a scratch path and keep it for the whole run, so concurrent sessions don't
clobber each other:

```sh
STATE=$(mktemp -d)/orig.diff
```

Then get the numbered diff. `prep` reads stdin, a revision, a range, `-w`, or
`-staged`; run it from inside the target repo so the paths resolve:

```sh
# a PR
gh pr diff <N> | MEATX_STATE=$STATE meatx prep > /tmp/prompt.txt 2>/tmp/excluded.txt
# a commit, a range, the working tree
MEATX_STATE=$STATE meatx prep <rev|range|-w|-staged> > /tmp/prompt.txt 2>/tmp/excluded.txt
```

`prep` drops generated files before numbering — lockfiles, vendored and build
output, snapshots, compiled protobufs and the like, across every ecosystem — and
names on stderr exactly what it excluded. This is a context saving, not a
judgment: a lockfile is routinely 90%+ of a scaffolding diff's bytes and none of
it is readable. Keep that stderr in `/tmp/excluded.txt` — step 4 puts it in the
page, so the reader can see what vanished before the abridging even started.
Read it yourself too, so nothing surprises you when you report.

The default set can't know your repo's conventions. Add to it, or opt out:

```sh
# also drop this project's generated or uninteresting paths
... | MEATX_STATE=$STATE meatx prep -x 'db/migrations/*' -x '*.pot'
# abridge everything, generated files included
... | MEATX_STATE=$STATE meatx prep -no-default-excludes
```

Exclude patterns: `*.lock` matches a basename, `a/b/*.py` matches a full path,
`dir/` matches that directory at any depth, `/dir/` only at the repo root.

Read `/tmp/prompt.txt`. It contains meat's own instructions plus the diff with a
1-based `N|` gutter. If it warns the diff exceeds one agent run, say so — the
plan will still compile, but meat proper would have chunked it. That threshold
is ~8,000 changed lines of ordinary source, so with generated files excluded it
is rarely reachable.

## 2. Plan

Write a JSON plan. Three op arrays, **all three required even when empty**:

```json
{
  "summary": "One line: what the change does, at the concept level.",
  "remove":  [{ "start_line": 17, "end_line": 25 }],
  "replace": [{ "line": 42, "old": "...", "new": "..." }],
  "fold":    [{ "start_line": 36, "end_line": 54 }]
}
```

Rules the compiler enforces — violating these is a hard reject, not a warning:

- Coordinates are the `N|` gutter numbers on the **original**, 1-based and
  inclusive. They never shift as you remove things. The gutter itself is not
  part of the line's text.
- `fold` needs **two or more contiguous lines of the same polarity** (all `+`,
  or all `-`, or all context). It collapses them to one indentation-preserving
  `...` row. Crossing a polarity boundary is rejected.
- `replace` elides *part of one line*. `new` must contain everything in `old`
  except spans visibly replaced by `...` or `…`. Use it rarely.
- Imports are stripped mechanically before you ever see the result. Never spend
  coordinates on them, never fold across them, never mention them in the summary.
- If move hints appear in the prompt, both sides of each pair need identical
  treatment. Asymmetric plans are rejected.

What to cut, in rough priority order:

- **A mechanical change repeated across N files.** Keep one representative file
  in full; `remove` the rest outright. This is usually the single biggest win.
- **Test bodies.** Keep the `it(`/`test(`/`def test_` names — they are the
  contract, and reading them in a list is the fastest way to see what the change
  claims. Fold the mock setup and assertion blocks under each.
- **Mechanical function bodies** — env plumbing, URL building, JSON marshalling,
  error-message construction, field-by-field copies.
- **Whole hunks that survive only as context** after imports are stripped.

What to keep, always:

- Doc comments and rationale. In this codebase they carry the design argument —
  the *why* — which is exactly what a reviewer cannot reconstruct from the code.
- Type and interface declarations, exported signatures.
- Control flow, conditions, lifecycle edges, retry/backoff decisions, security
  boundaries, and anything a comment flags as a caveat or hazard.

## 3. Apply

```sh
MEATX_STATE=$STATE meatx apply /tmp/plan.json > /tmp/reading.diff
```

Invalid plans are rejected with a reason on stderr — fix and re-run, that loop
is cheap. On success stderr carries the retention feedback:

```
Retention: 249/612 visible changed rows (40%); 98 removed, 299 hidden by 34 folds; files 6/9.
```

**Do at most one refinement pass.** Tighten if retention is above ~45%, or if
scanning the output shows something obviously mechanical still in full. Then
stop. The "Pressure: high retention" line fires on any diff with more than 80
visible rows, so on a large PR it is essentially always present — treat it as
advisory, never as a gate to loop against.

## 4. Show it

`meat-view` renders the reading diff as a side-by-side HTML page and opens it in
the browser, to be read in a tab beside the PR itself. Run it from inside the
target repo — the page lands in that repo's git-ignored `scratch/meat-diffs/`:

```sh
meat-view /tmp/reading.diff \
  --orig "$STATE" \
  --excluded /tmp/excluded.txt \
  --pr 175 \
  --target pr-175 \
  --title "PR #175 — drop the v1 compatibility layer" \
  --note "The four deleted tests keep their names; fixtures and assertions are
folded. Eight call sites got the same mechanical rename — kept client.ts as the
representative and dropped the rest."
```

`--target` names the file, so use what was abridged: `pr-<N>`, the short sha, a
sanitized rev, `worktree`, or `staged`. Never leave it off — the default is a
characterless `reading.html`. Repeat runs are numbered rather than overwritten,
so prior renders survive.

Say what the diff is against: `--pr <N>` when you abridged a PR, `--commit
<rev>` when you abridged a commit. Either one puts a link to it on GitHub in
the header band, so the page can be read beside its source. `--pr` also puts a
copyable *watch checks, then merge* command at the bottom — the same one the
`merge` skill runs — behind a copy-to-clipboard button. Leave both off for
`-w` and `-staged`; there is nothing to link to.

The page carries its own provenance, which is why the flags matter. `--orig`
lets it derive which files were dropped whole, by comparing `$STATE`'s file list
against the reading diff's. `--excluded` surfaces what `prep` skipped as
generated. `--note` is the one thing no script can derive — *why* what went
missing was safe to lose, in your words. Write it as prose, and name the
representative file whenever you kept one and dropped its siblings.

Line numbers are hidden in the page: folds make them drift within a hunk, so
they would be quietly wrong. The `@@` headers stay, and are accurate.

Then keep the terminal short — the page is the artifact, not the transcript.
Three lines: the path it printed, the retention numbers, and the one-line
summary. The full account of what you dropped belongs in `--note`, not here.

## Notes

- `meatx` is a shim over boldsoftware/meat, forked to
  [thavelick/meat](https://github.com/thavelick/meat) and worked on in
  `~/Projects/meat`. It makes **no API call** — you are the model, and the work
  runs on the session's existing subscription. See [INSTALL.md](INSTALL.md).
- The reading diff is deliberately **not an applicable patch**: hunk line counts
  go stale where rows were dropped, so line numbers drift within any hunk you
  cut. Never feed the output to `git apply`.
- `meat-view` lives in `bin/meat-view` in the dotfiles repo, with its page
  template beside it. It shells out to `bunx diff2html-cli@5.2.15` — pinned, so
  an upstream change breaks loudly instead of quietly restyling the page — and
  opens the result with `qopen`. Nothing to install: `bunx` fetches on first
  use and caches.
- Chunking for very large diffs lives behind meat's own `Abridge` and is not
  wired up here.
