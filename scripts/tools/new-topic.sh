#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: scripts/tools/new-topic.sh N01 short-slug"
  exit 1
fi

ID="$1"
SLUG="$2"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DIR="$ROOT/outputs/${ID}-${SLUG}"
DATE_NOW="$(date '+%Y-%m-%d %H:%M:%S')"

mkdir -p "$DIR/images" "$DIR/videos"

cp "$ROOT/templates/source-log-template.md" "$DIR/00-source-log.md"
cp "$ROOT/templates/topic-card-template.md" "$DIR/01-topic-card.md"
cp "$ROOT/templates/script-template.md" "$DIR/02-script.md"
cp "$ROOT/templates/shot-image-prompts-template.md" "$DIR/03-image-prompts.md"
cp "$ROOT/templates/seedance-prompts-template.md" "$DIR/04-seedance-prompts.md"
cp "$ROOT/templates/publish-copy-template.md" "$DIR/05-publish-copy.md"
cp "$ROOT/templates/assets-manifest-template.md" "$DIR/06-assets-manifest.md"
cp "$ROOT/templates/production-checklist-template.md" "$DIR/07-production-checklist.md"

perl -0pi -e "s/NXX/${ID}/g; s/NXX/${ID}/g" \
  "$DIR/00-source-log.md" \
  "$DIR/01-topic-card.md" \
  "$DIR/02-script.md" \
  "$DIR/03-image-prompts.md" \
  "$DIR/04-seedance-prompts.md" \
  "$DIR/05-publish-copy.md" \
  "$DIR/06-assets-manifest.md" \
  "$DIR/07-production-checklist.md"

cat > "$ROOT/queue/inbox/${ID}-${SLUG}.md" <<EOF
# ${ID} ${SLUG}

- status: inbox
- output_dir: outputs/${ID}-${SLUG}
- created: ${DATE_NOW}
- notes: create source log before script
EOF

echo "Created: $DIR"
