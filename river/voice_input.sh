#!/bin/bash

# Simple voice input script for river
# Gets text input and copies it to clipboard

echo "Voice Input - Enter text to copy:"
read -r user_input

if [ -n "$user_input" ]; then
    echo "$user_input" | wl-copy
    echo "Text copied to clipboard: $user_input"
    echo "You can now paste it with Ctrl+V"
else
    echo "No text entered"
fi