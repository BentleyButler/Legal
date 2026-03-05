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

# --- ADDED BY URKEL --- (Backup Logging & Error Alerting)
if [ $? -eq 0 ]; then
  changed_files=$(git diff --name-status HEAD~1 HEAD 2>/dev/null || echo "Initial commit or no history")
  echo "[$(date -u +'%Y-%m-%d %H:%M:%S UTC')] SUCCESS: $WORKSPACE_DIR" >> /home/bentl/.openclaw/workspace/logs/backup-status.log
  echo "Changed files:" >> /home/bentl/.openclaw/workspace/logs/backup-status.log
  echo "$changed_files" >> /home/bentl/.openclaw/workspace/logs/backup-status.log
  echo "----------------------------------------" >> /home/bentl/.openclaw/workspace/logs/backup-status.log
else
  echo "[$(date -u +'%Y-%m-%d %H:%M:%S UTC')] FAILED: $WORKSPACE_DIR" >> /home/bentl/.openclaw/workspace/logs/backup-status.log
  # Push a system notification about the failure
  /home/bentl/.npm-global/bin/openclaw notify "Backup Failed for $WORKSPACE_DIR" "Please check /home/bentl/.openclaw/workspace/logs/backup-status.log" || true
fi
# --- END ADDED ---
