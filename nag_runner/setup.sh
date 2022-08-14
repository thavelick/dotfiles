#!/bin/sh

nag_runner_path="$HOME/Projects/nag-runner"
[ ! -d "$nag_runner_path" ] && git clone git@github.com:thavelick/nag-runner.git $nag_runner_path
[ -f "/etc/arch-release" ] && ln -svf $DOTFILES_HOME/nag_runner/nag_runner.arch.json $HOME/.config/nag_runner.json
