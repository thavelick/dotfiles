---
name: cut-branch
description: Create a new git branch for working on a feature or fix
argument-hint: "[issue-number or description]"
---

Create a new git branch following the naming convention: `description_of_issue_<github-issue-number>`

## Process

1. **Determine the issue number**:
   - If `$ARGUMENTS` contains a number, use that as the issue number
   - If `$ARGUMENTS` is empty or doesn't contain an issue number, ask the user for it
   - The user may say there is no ticket - that's okay, proceed without one

2. **Check for existing branch** (if there is an issue number):
   - Run: `git pull && git branch -a | grep _<number>$`
   - If a branch already exists for this issue, ask the user if they want to check it out instead (skip remaining steps)

3. **Fetch issue details** (if there is an issue number):
   1. Check if the project has a `.issues` directory by running: `[ -d .issues ] && echo ".issues directory found" || echo ".issues directory not found"`
   2. If the `.issues` directory exists: use `gh-issue-sync pull && gh-issue-sync view <number>` to get the issue title
   3. If the `.issues` directory does NOT exist: use `gh issue view <number>` to get the issue title

4. **Generate branch name**:
   - Use your judgment to create a short, descriptive branch name based on the issue title
   - Use underscores between words, keep it lowercase
   - If there's an issue number, append `_<number>` at the end

5. **Create and checkout the branch**:
   ```bash
   git checkout -b <branch-name>
   ```

6. **Confirm to the user** what branch was created and from what base branch.

## Examples

- Issue #42 titled "Fix login button alignment" → `fix_login_button_42`
- Issue #100 titled "Add OAuth2 support for third-party apps" → `oauth2_support_100`
- No ticket, user describes "refactor database queries" → `refactor_db_queries`
