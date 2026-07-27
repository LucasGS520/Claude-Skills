#!/usr/bin/env bash
# Reproduces this Claude Code skills/plugins setup on a new machine.
# Run from the root of this repo: ./install.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_ROOT/.claude/skills"
SKILLS_DST="$HOME/.claude/skills"
MANIFEST="$REPO_ROOT/plugins.json"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "== Folder-based skills =="
mkdir -p "$SKILLS_DST"
if [ -d "$SKILLS_SRC" ]; then
  for dir in "$SKILLS_SRC"/*/; do
    name="$(basename "$dir")"
    # --exclude drops stray embedded-git backups (e.g. dev--security-auditor)
    # that ship with permission-locked pack files and aren't real skill content.
    tar --exclude='.git.embedded-backup' -cf - -C "$SKILLS_SRC" "$name" | tar -xf - -C "$SKILLS_DST"
    echo "  copied $name"
  done
else
  echo "  no $SKILLS_SRC found, skipping"
fi

python3 - "$MANIFEST" "$TMP_DIR" <<'PYEOF'
import json, sys
manifest, tmp_dir = sys.argv[1], sys.argv[2]
with open(manifest) as f:
    data = json.load(f)
with open(f"{tmp_dir}/marketplaces.tsv", "w", newline="\n") as f:
    for m in data["marketplaces"]:
        f.write(f"{m['name']}\t{m['url']}\n")
with open(f"{tmp_dir}/plugins.txt", "w", newline="\n") as f:
    for p in data["plugins"]:
        f.write(f"{p}\n")
PYEOF

echo
echo "== Plugin marketplaces =="
mapfile -t MARKETPLACE_LINES < "$TMP_DIR/marketplaces.tsv"
for line in "${MARKETPLACE_LINES[@]}"; do
  name="${line%%$'\t'*}"
  url="${line#*$'\t'}"
  if claude plugin marketplace list 2>/dev/null | grep -qi "^  ❯ $name\$"; then
    echo "  $name already added, skipping"
  else
    echo "  adding $name ($url)"
    claude plugin marketplace add "$url" </dev/null
  fi
done

echo
echo "== Refreshing marketplace cache =="
claude plugin marketplace update </dev/null

echo
echo "== Plugins =="
mapfile -t PLUGIN_LINES < "$TMP_DIR/plugins.txt"
for plugin in "${PLUGIN_LINES[@]}"; do
  [ -z "$plugin" ] && continue
  echo "  installing $plugin"
  claude plugin install "$plugin" </dev/null || echo "  (failed or already installed: $plugin)"
done

echo
echo "Done. Restart Claude Code session to pick up new skills/plugins."
