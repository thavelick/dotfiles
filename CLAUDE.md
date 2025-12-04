# Claude Code Usage Notes

## Project Structure
This repository contains a modular, portable dotfiles configuration supporting multiple operating systems and environments.

### Main Components
- **zsh/**: Modular zsh configuration with aliases, functions, plugins, prompt, and key bindings
- **river/**: River window manager configuration and scripts
- **waybar/**: Status bar configuration
- **foot/**: Terminal emulator configuration
- **tmux/**: Terminal multiplexer configuration
- **vim/**: Vim editor configuration
- **git/**: Git configuration and setup
- **whisper/**: Voice input transcription system
- **systemd/**: System service configurations
- **claude/**: Claude Code configuration (CLAUDE.md and custom slash commands)
- **arch/**: Arch Linux package lists and configurations
- **debian/**: Debian/Ubuntu package management
- **mac/**: macOS-specific configurations

## Development
- Use the `scratch/` directory for one-off debugging scripts and temporary files
- `scratch/` is gitignored, so it's safe for experimentation
- Claude can create and run scripts in `scratch/` for debugging
- Example: `scratch/debug_fzf.zsh` - script to debug FZF loading issues

### Development Workflow
- Always do work on a new branch, not main
- When working on a ticket, put the ticket number in commit message and PR
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
- When we merge via gh, it deletes the branch on remote AND LOCAL and checks out main for us
- Before commiting run `make lint` to find any new problems

## Testing
- `make test`: Run automated tests in minimal Debian container
- `make test-core`: Run tests in Arch Linux container
- `make test-all`: Run both test suites
- `make build` / `make build-core`: Build Docker test images
- `make run`: Start persistent Debian development container
- `make shell`: Shell into running container (optional cmd parameter: `make shell cmd="ls -la"`)
- `make destroy`: Destroy the persistent container
- After making changes to zsh config, test by sourcing `.zshrc` and running manual tests
- Check FZF integration with Ctrl+R for history search
- Test aliases like `ls`, `vim`, `namedcat`
- Verify prompt shows correct OS icons and git status

## Linting and Formatting
- `make lint`: Run shellcheck on shell files and ruff on Python files
- `make format`: Format Python files with black
- `make check-secret TARGET=path`: Check files/directories for secrets using gitleaks

## Voice Input System
- Located in `whisper/` directory
- Real-time streaming transcription with threading
- Alt+Z hotkey activation
- Python-based with voice activity detection

## Code Style
- Use comments sparingly to explain intent (answer "why") for future readers
- Avoid comments that explain what Claude is doing or what the code does
- Comments should add value, not state the obvious
- Shell scripts should pass shellcheck linting
- Python code should follow ruff/black formatting standards