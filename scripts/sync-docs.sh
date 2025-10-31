#!/bin/zsh
NOTES_DIR="$HOME/Documents"  

cd "$NOTES_DIR" || exit 1

echo "Syncing documents..."
git add .
if git diff --staged --quiet; then
    echo "No local changes to commit"
else
    git commit -m "Auto sync $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Local changes committed"
fi

# Pull from GitHub
echo "Pulling..."
git pull --rebase origin main

# Push to GitHub
echo "Pushing..."
git push origin main

echo "✓ Synced up!"
