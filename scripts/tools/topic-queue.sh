#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
QUEUE_DIR="$ROOT/queue"

cmd="${1:-status}"
arg="${2:-}"

list_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    find "$dir" -maxdepth 1 -type f | sort
  fi
}

case "$cmd" in
  status)
    echo "inbox: $(find "$QUEUE_DIR/inbox" -maxdepth 1 -type f | wc -l | tr -d ' ')"
    echo "ready: $(find "$QUEUE_DIR/ready" -maxdepth 1 -type f | wc -l | tr -d ' ')"
    echo "in-progress: $(find "$QUEUE_DIR/in-progress" -maxdepth 1 -type f | wc -l | tr -d ' ')"
    echo "done: $(find "$QUEUE_DIR/done" -maxdepth 1 -type f | wc -l | tr -d ' ')"
    ;;
  list)
    if [[ -z "$arg" ]]; then
      echo "Usage: scripts/tools/topic-queue.sh list inbox|ready|in-progress|done"
      exit 1
    fi
    list_dir "$QUEUE_DIR/$arg"
    ;;
  next)
    find "$QUEUE_DIR/ready" -maxdepth 1 -type f | sort | head -n 1
    ;;
  *)
    echo "Usage:"
    echo "  scripts/tools/topic-queue.sh status"
    echo "  scripts/tools/topic-queue.sh list inbox|ready|in-progress|done"
    echo "  scripts/tools/topic-queue.sh next"
    exit 1
    ;;
esac
