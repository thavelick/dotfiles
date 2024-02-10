#!/bin/sh
nag_runner_path="$HOME/Projects/nag-runner"
[ ! -d "$nag_runner_path" ] && git clone git@github.com:thavelick/nag-runner.git "$nag_runner_path"
nag_runner_config_file=""
[ -f "/etc/arch-release" ] && nag_runner_config_file="$DOTFILES_HOME/nag_runner/nag_runner.arch.json"
[ -f "/etc/debian_version" ] && nag_runner_config_file="$DOTFILES_HOME/nag_runner/nag_runner.debian.json"
[ -n "$nag_runner_config_file" ] && ln -svf "$nag_runner_config_file" "$HOME/.config/nag_runner.json"
exit 0
