#!/bin/sh

dwm_path="$HOME/Projects/dwm"
[ ! -d "$dwm_path" ] && git clone git@github.com:thavelick/dwm.git $dwm_path
cd $dwm_path && sudo make install
