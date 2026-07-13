---
name: issue
description: Create or update GitHub issues via a scratch working file. Use when the user wants to draft a new issue, edit an existing issue, or push issue changes to GitHub with gh.
argument-hint: [new "<title>" | <issue-number>]
allowed-tools: Bash(gh *), Bash(mkdir *), Bash(mv *), Bash(cp *), Read, Write, Edit
---

# Manage GitHub Issues

Draft and edit GitHub issues in a local scratch file, then push with `gh`.
The scratch directory is `scratch/` at the project root. Never push to GitHub
until the user has explicitly approved the draft.

Decide the flow from `$ARGUMENTS`:

- `new "<title>"` or no arguments → **Create flow**
- An issue number (e.g. `42`) → **Update flow**

## Create flow

1. Ensure the scratch dir exists: `mkdir -p scratch`.
2. Create the scratch draft under a slugified title
   (`scratch/new-issue-<slug>.md`, where `<slug>` is the title lowercased with
   spaces → hyphens):
   - **If the repo has an issue template** (check `.github/ISSUE_TEMPLATE/` — use
     `new_issue.md` if present, otherwise pick the most fitting template there),
     copy it into scratch, e.g.
     `cp .github/ISSUE_TEMPLATE/new_issue.md scratch/new-issue-<slug>.md`.
   - **If there is no template**, write a fresh draft with `title:` frontmatter
     and sensible default sections (e.g. Description, Tasks).
3. Open the draft and set the `title:` frontmatter to the requested title.
   Fill in the body sections (whatever the template defines, or the defaults
   above) based on what the user describes. Ask clarifying questions when the
   requirements are thin. It's fine to leave a section blank if it isn't
   relevant to this issue, and leave any template comments explaining how a
   section should be used in place.
4. Show the draft and **wait for explicit approval**. Iterate on request.
5. On approval, create the issue with `gh`. The template frontmatter (name,
   about, title, labels, assignees) is GitHub template metadata — strip it from
   the body before submitting. Pass the title with `-t` and the body via a
   file with `-F`:
   ```
   gh issue create -t "<title>" -F <body-file> [--label <labels>] [--assignee <assignees>]
   ```
   Write the body-without-frontmatter to a temp file (e.g. under the session
   scratchpad) and pass it to `-F`.
6. Capture the new issue number from the `gh` output, then rename the scratch
   file: `mv scratch/new-issue-<slug>.md scratch/issue-<num>.md`.
7. Report the created issue number and URL.

## Update flow

1. Ensure the scratch dir exists: `mkdir -p scratch`.
2. Pull the current issue into scratch:
   ```
   gh issue view <num> --json title,body -q '"---\ntitle: \(.title)\n---\n\n\(.body)"' > scratch/issue-<num>.md
   ```
   (Or read the fields and write the file yourself.) Always overwrite the
   scratch copy so it reflects the live issue before editing.
3. Make the requested changes to `scratch/issue-<num>.md`.
4. Show the changes and **wait for explicit approval**. Iterate on request.
5. On approval, push the update. Send the body (without the `title:`
   frontmatter) via a file, and update the title if it changed:
   ```
   gh issue edit <num> -t "<title>" -F <body-file>
   ```
6. Report what changed and the issue URL.

## Notes

- Keep the scratch file as the single source of truth during a drafting
  session; edit it, not the terminal.
- Do not run `gh issue create` or `gh issue edit` until the user approves.
- If `gh` is not authenticated, tell the user to run `gh auth login` (they can
  type `!gh auth login` in the prompt).
