#!/bin/bash
set -e

# Build list of documents from both directories if they exist
documents=""

if [ -d "$HOME/Documents" ]; then
    documents=$(find "$HOME/Documents" -type f 2>/dev/null)
fi

if [ -d "$HOME/nextcloud/Documents" ]; then
    nextcloud_docs=$(find "$HOME/nextcloud/Documents" -type f 2>/dev/null)
    if [ -n "$documents" ]; then
        documents="$documents"$'\n'"$nextcloud_docs"
    else
        documents="$nextcloud_docs"
    fi
fi

# Exit if no documents found
if [ -z "$documents" ]; then
    exit 1
fi

# Ensure history file exists
touch "$HOME/.cache/document_history"

# Get documents we've previously opened, excluding any that don't exist anymore
documents_from_history=$(grep -xFf <(echo -e "$documents") "$HOME/.cache/document_history" 2>/dev/null || true)

# Make a list of all documents, sorted by frequency they've been opened via this picker
frequency_sorted_documents=$(echo -e "$documents\n$documents_from_history" | sort | uniq -c | sort -nr | awk '{print $2}')

document_picked=$(echo -e "$frequency_sorted_documents" | sed "s|$HOME|~|g" | fzf | sed "s|~|$HOME|g")

# Exit if nothing selected
[ -z "$document_picked" ] && exit 1

# Save the selected document to history
echo "$document_picked" >> "$HOME/.cache/document_history"

# Open the selected document with xdg-open via riverctl spawn
riverctl spawn "xdg-open \"$document_picked\""