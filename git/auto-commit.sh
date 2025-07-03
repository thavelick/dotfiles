#!/bin/bash
echo "staging files"
git add --intent-to-add .
git add -p

echo "generating commit message"
diff=$(git diff --staged)
commit_msg=$($HOME/Projects/ai-asker/ask.py "write a good commit message for this diff: $diff")

echo $commit_msg
git commit -m "$commit_msg"