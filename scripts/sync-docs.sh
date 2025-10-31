#!/bin/zsh
NOTES_DIR="$HOME/Documents"  # adjust to your path

cd "$NOTES_DIR" || exit 1

echo "Syncing notes..."

# Add and commit any local changes
git add .
if git diff --staged --quiet; then
    echo "No local changes to commit"
else
    git commit -m "Auto sync $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Local changes committed"
fi

# Pull from GitHub (get remote changes)
echo "Pulling from GitHub..."
git pull --rebase origin main

# Push to GitHub (send local changes)
echo "Pushing to GitHub..."
git push origin main

echo "✓ Sync complete!"
