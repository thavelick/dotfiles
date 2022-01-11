#!/bin/zsh 
# Copyright (C) 2001-2020  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2022 Tristan Havelick (tristan@havelick.com) 
#  for modifications to work with zsh
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Gemini
#
#
# Here's how to read "gemini://alexschroeder/Test":
#
#     gemini gemini://alexschroeder.ch:1965/Test
#
# The scheme and port are optional:
#
#     gemini alexschroeder.ch/Test
#

# To install, source this file from your ~/.zshrc file:
#
#     source gemini.zsh

gemini () {
    setopt local_options BASH_REMATCH
    if [[ $1 =~ ^((gemini)://)?([^/:]+)(:([0-9]+))?/(.*)$ ]]; then
	  schema=${BASH_REMATCH[3]:-gemini}
	  echo "schema: $schema"
	  host=${BASH_REMATCH[4]}
      echo "host: $host"
	  port=${BASH_REMATCH[5]:-1965}
	  echo "port: $port"
	  url_path=${BASH_REMATCH[7]}
	  echo "url path: $url_path"
	  echo Contacting $host:$port...
	  echo -e "$schema://$host:$port/$url_path\r\n" \
	    | openssl s_client -quiet -connect "$host:$port" 2>/dev/null
    else
	  echo $1 is not a Gemini URL
    fi
}


