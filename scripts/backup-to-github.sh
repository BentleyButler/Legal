#!/bin/bash
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_DIR"

# use dedicated deploy key for unattended pushes
export GIT_SSH_COMMAND="ssh -i /home/bentl/.ssh/id_ed25519_backup -o IdentitiesOnly=yes"

# require remote
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "No git remote 'origin' configured for Legal workspace. Skipping backup."
  exit 0
fi

# exit if clean
if [[ -z "$(git status --porcelain)" ]]; then
  exit 0
fi

timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

git add -A
git commit -m "Auto backup ${timestamp}"
git push origin main
