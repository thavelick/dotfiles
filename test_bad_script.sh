#!/bin/bash

# This script intentionally has shellcheck issues
echo "Testing shellcheck failure"

# SC2086: Missing quotes around variable
cd $HOME

# SC2164: cd without error checking
cd /nonexistent/path

# SC2046: Unquoted command substitution 
files=$(ls *.txt)
echo Found files: $files