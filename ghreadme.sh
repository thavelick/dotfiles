#!/bin/bash
set -e
gh_url=$1
gh_user=$(echo "${gh_url}" | cut -f4 -d '/')
gh_repo=$(echo "${gh_url}" | cut -f5 -d '/')
gh_response=$(curl -s "https://api.github.com/repos/${gh_user}/${gh_repo}/readme" || echo "nope")
has_content=$(echo "$gh_response" | jq -r 'has("content")')
[[ $has_content == "true" ]] && echo "$gh_response" | jq -r .content | base64 -d | less
