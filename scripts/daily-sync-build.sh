#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_FILE="/tmp/openclaw-daily-sync.log"

# launchd 的 PATH 很精简，需要手动加载 nvm
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

notify() {
  local title="$1"
  local msg="$2"
  osascript -e "display notification \"$msg\" with title \"$title\""
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

fail() {
  log "ERROR: $*"
  notify "OpenClaw 同步失败" "$*"
  exit 1
}

log "===== 开始每日同步构建 ====="

cd "$ROOT_DIR"

log "通过 GitHub API 同步 fork..."
# 用 gh 在 GitHub 云端将 zy-jordan/openclaw 同步到上游最新，不需要本地 push
gh repo sync zy-jordan/openclaw --source openclaw/openclaw --branch main \
  || fail "gh repo sync 失败"

log "拉取到本地..."
git pull origin main || fail "git pull 失败"