# Installing meatx

The `meat` skill drives `meatx`, a small CLI over a personal fork of
[boldsoftware/meat](https://github.com/boldsoftware/meat). Upstream `meat` calls
an LLM API itself; `meatx` splits that apart so the agent already in the session
supplies the judgment, and no API key or provider call is involved.

- Fork: <https://github.com/thavelick/meat>
- Working copy: `~/Projects/meat`, on `main`
- Binary: `~/go/bin/meatx` (already on `$PATH` via `zsh/core.zsh`)

The fork follows upstream's own habit: one branch, linear history, no merge
commits. Our commits sit directly on top of theirs.

## Requirements

- **Go** — 1.26+. `brew install go` / `pacman -S go`.
- **bun** — for `bunx`, which `meat-view` uses to render the page. No global
  install of `diff2html-cli` is needed; `bunx` fetches the pinned version on
  first use and caches it.
- **gh** — only for abridging PRs by number.

`meat-view` and `qopen` both ship in this repo's `bin/`, already on `$PATH`.

Upstream has no third-party dependencies, so there is nothing to `go mod
download`.

## First install

```sh
git clone git@github.com:thavelick/meat.git ~/Projects/meat
cd ~/Projects/meat
git remote add upstream https://github.com/boldsoftware/meat.git
go build -o ~/go/bin/meatx ./cmd/meatx
```

Verify:

```sh
meatx                       # prints usage
go test ./...               # upstream suite + the filter tests
```

## Rebuild after changing the fork

```sh
cd ~/Projects/meat && go build -o ~/go/bin/meatx ./cmd/meatx
```

## Updating from upstream

Our two commits sit on top of upstream's `main`, so an update is a rebase that
replays them onto whatever they have added:

```sh
cd ~/Projects/meat
git fetch upstream
git rebase upstream/main
go test ./... && go build -o ~/go/bin/meatx ./cmd/meatx
git push --force-with-lease origin main
```

The force-push is expected — rebasing rewrites our two commits onto new parents.
`--force-with-lease` refuses if the fork moved underneath you.

**Expect this to break occasionally, and expect it to break loudly.**
`meat/agentshim.go` is a re-export of unexported internals — `numberedDiff`,
`buildUserPrompt`, `compileSubmission`, `editPlanToolSchema`, `fitsSingleRun`.
An upstream rename fails the build rather than silently changing behavior, so a
red `go build` after a rebase means "a name moved", not "the abridging is
wrong". Fix by finding the new name in `meat/`.

## What the fork adds

Two commits on top of upstream's tip, each building and passing tests on its
own (so a bisect never lands on a broken state):

- `meat/agentshim.go` — `Prepare` stops just before the model call and returns
  the assembled prompt; `ApplyPlan` compiles an externally-authored edit plan
  with the same validation `submit` performs. Re-exports only, no behavior
  change.
- `cmd/meatx` — `prep` and `apply`, plus the generated-file filter that drops
  lockfiles, vendored output, snapshots and compiled artifacts before numbering,
  naming on stderr whatever it dropped.

## Known limits

- **Chunking is not wired up.** Diffs over ~400KB numbered (roughly 8,000
  changed lines of ordinary source) would be split by upstream `Abridge`;
  `meatx prep` only warns. Rarely reachable once generated files are excluded.
- **The output is not an applicable patch.** Hunk counts go stale wherever rows
  were dropped, so line numbers drift within a cut hunk — which is why
  `meat-view` hides them. Never `git apply` it.
- **Files are never reordered**, only dropped — so a move between files still
  shows its two sides far apart, wherever git put them.
