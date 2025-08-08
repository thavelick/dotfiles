#!/bin/bash
set -e

# Find documents
doc_dirs=()
[ -d "$HOME/Documents" ] && doc_dirs+=("$HOME/Documents")
[ -d "$HOME/nextcloud/Documents" ] && doc_dirs+=("$HOME/nextcloud/Documents")
[ ${#doc_dirs[@]} -eq 0 ] && exit 1
documents=$(find "${doc_dirs[@]}" -type f -print0 2>/dev/null | tr '\0' '\n')
[ -z "$documents" ] && exit 1

# Sort by usage frequency
touch "$HOME/.cache/document_history"
documents_from_history=$(grep -xFf <(printf '%s\n' "$documents") "$HOME/.cache/document_history" 2>/dev/null || true)
frequency_sorted_documents=$(printf '%s\n%s\n' "$documents" "$documents_from_history" | sort | uniq -c | sort -nr | awk '{$1=""; print substr($0,2)}')

# Pick and open document
document_picked=$(printf '%s\n' "$frequency_sorted_documents" | sed "s|$HOME|~|g" | fzf | sed "s|~|$HOME|g")
[ -z "$document_picked" ] && exit 1

echo "$document_picked" >> "$HOME/.cache/document_history"

# Check if the default application is a terminal app
mime_type=$(xdg-mime query filetype "$document_picked")
default_app=$(xdg-mime query default "$mime_type")
desktop_file="/usr/share/applications/$default_app"

if [ -f "$desktop_file" ] && grep -qE "Terminal=true" "$desktop_file"; then
    riverctl spawn "foot xdg-open \"$document_picked\""
else
    riverctl spawn "xdg-open \"$document_picked\""
fi
