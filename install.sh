#!/usr/bin/env bash
# Reproduces this Claude Code skills/plugins setup on a new machine.
# Run from the root of this repo: ./install.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_ROOT/.claude/skills"
SKILLS_DST="$HOME/.claude/skills"
MANIFEST="$REPO_ROOT/plugins.json"

echo "== Folder-based skills =="
mkdir -p "$SKILLS_DST"
if [ -d "$SKILLS_SRC" ]; then
  for dir in "$SKILLS_SRC"/*/; do
    name="$(basename "$dir")"
    cp -r "$dir" "$SKILLS_DST/"
    echo "  copied $name"
  done
else
  echo "  no $SKILLS_SRC found, skipping"
fi

echo
echo "== Plugin marketplaces & plugins =="
if [ -f "$MANIFEST" ]; then
  python3 - "$MANIFEST" <<'PYTHON'
import json
import subprocess
import sys

manifest_path = sys.argv[1]
with open(manifest_path) as f:
  data = json.load(f)

# Add marketplaces
for mp in data.get("marketplaces", []):
  name, url = mp["name"], mp["url"]
  result = subprocess.run(
    ["claude", "plugin", "marketplace", "add", url],
    capture_output=True, text=True
  )
  if result.returncode == 0 or "already" in result.stderr.lower():
    print(f"  marketplace {name} ready")
  else:
    print(f"  error adding {name}: {result.stderr}", file=sys.stderr)
    sys.exit(1)

# Install plugins
for plugin in data.get("plugins", []):
  result = subprocess.run(
    ["claude", "plugin", "install", plugin],
    capture_output=True, text=True
  )
  if result.returncode == 0 or "already" in result.stderr.lower():
    print(f"  installed {plugin}")
  else:
    print(f"  error installing {plugin}: {result.stderr}", file=sys.stderr)
    sys.exit(1)
PYTHON
else
  echo "  no $MANIFEST found, skipping"
fi

echo
echo "== Done =="
echo "Skills + plugins installed. Run 'claude' to verify."
