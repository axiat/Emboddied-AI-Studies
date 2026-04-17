#!/bin/bash
# Quick deploy: build locally to verify, then push to trigger GitHub Actions
set -e

cd "$(dirname "$0")"

echo "Building site locally to verify..."
hugo --minify

TARGETS=("$@")
if [ ${#TARGETS[@]} -eq 0 ]; then
  TARGETS=(content/posts config.toml assets layouts static)
fi

echo ""
echo "Build succeeded. Staging site changes..."
git add "${TARGETS[@]}"

if git diff --cached --quiet; then
  echo "No staged changes to publish."
  exit 0
fi

echo "Pushing to GitHub..."
git commit -m "publish: $(date +%Y-%m-%d) update"
git push origin main

echo ""
echo "Pushed. GitHub Actions will deploy automatically."
echo "Check: https://github.com/axiat/Emboddied-AI-Studies/actions"
