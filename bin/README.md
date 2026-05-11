# bin/

Standalone scripts on `$PATH`. **Default choice** for any new shell utility — prefer this over aliases or functions unless you have a specific reason not to.

Only reach for an alias (`zsh/aliases.sh`) or function (`zsh/functions.zsh`) when the alternative is technically required — e.g. the logic must mutate the current shell (`cd`, set vars, capture `$?`), or it uses zsh builtins/widgets that don't exist outside the running shell.

Shell scripts must pass `shellcheck` (enforced by `make lint`).
