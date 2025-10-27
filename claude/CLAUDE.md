## GitHub Ticket Workflow
- When user says "let's do a ticket", find a GitHub ticket using gh CLI
- Prefer older tickets first
- Only consider tickets created by thavelick
- When starting a ticket always cut a new branch. It should have a name like a_description_123 where 123 is the ticket number.
- When adding comments to tickets or PRs always attribute the comments to Claude. Otherwise they look like they're coming from the user
- use `trashit` instead of `rm` when removing files or directories
- to copy and paste from the user's clipboard use `qpaste` and `qcopy`. They work roughly like pbcopy and pbpaste on mac but are cross-platform