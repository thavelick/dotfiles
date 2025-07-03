# Claude Code Usage Notes

## Project Structure
This repository contains a modular, portable zsh configuration.

## Development
- Use the `scratch/` directory for one-off debugging scripts and temporary files
- `scratch/` is gitignored, so it's safe for experimentation
- Claude can create and run scripts in `scratch/` for debugging
- Example: `scratch/debug_fzf.zsh` - script to debug FZF loading issues

### Development Workflow
- Always do work on a new branch, not main
- When user says "Review time":
  a. Make sure we're not on main branch
  b. Commit what we've done
  c. Push to remote
  d. Create a PR with `gh`
- When user says "made suggestions on the pr":
  - Get PR comments with `gh api repos/OWNER/REPO/pulls/PULL_NUMBER/comments`
  - Address those comments
  - Watch out for multiple PR comments on one code line
- When user says "merge", do a gh pr merge with a merge commit and use the option to delete local and remote branches

## Testing
- After making changes to zsh config, test by sourcing `.zshrc` and running manual tests
- Check FZF integration with Ctrl+R for history search
- Test aliases like `ls`, `vim`, `namedcat`
- Verify prompt shows correct OS icons and git status

## Code Style
- Use comments sparingly to explain intent (answer "why") for future readers
- Avoid comments that explain what Claude is doing or what the code does
- Comments should add value, not state the obvious