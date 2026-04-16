#!/bin/bash
# Quick deploy: build locally to verify, then push to trigger GitHub Actions
set -e

cd "$(dirname "$0")"

echo "Building site locally to verify..."
hugo --minify

echo ""
echo "Build succeeded. Pushing to GitHub..."
git add -A
git commit -m "publish: $(date +%Y-%m-%d) update"
git push origin main

echo ""
echo "Pushed. GitHub Actions will deploy automatically."
echo "Check: https://github.com/axiat/Emboddied-AI-Studies/actions"
