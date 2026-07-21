#!/usr/bin/env bash
set -euo pipefail

# Links all skills in the repository into local agent skill directories.
#
# Usage:
#   scripts/link-skills.sh           # link to Claude and Codex
#   scripts/link-skills.sh claude    # link to Claude only
#   scripts/link-skills.sh codex     # link to Codex only
#   scripts/link-skills.sh all       # link to Claude and Codex

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-all}"

case "$TARGET" in
  all | claude | codex) ;;
  *)
    echo "usage: $0 [all|claude|codex]" >&2
    exit 2
    ;;
esac

destinations=()

if [ "$TARGET" = "all" ] || [ "$TARGET" = "claude" ]; then
  destinations+=("$HOME/.claude/skills")
fi

if [ "$TARGET" = "all" ] || [ "$TARGET" = "codex" ]; then
  destinations+=("$HOME/.agents/skills")
fi

link_skill() {
  local dest="$1"
  local src="$2"
  local name
  local target

  name="$(basename "$src")"
  target="$dest/$name"

  mkdir -p "$dest"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "skipped $target: exists and is not a symlink" >&2
    return 0
  fi

  ln -sfn "$src" "$target"
  echo "linked $target -> $src"
}

for dest in "${destinations[@]}"; do
  find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -print0 |
  while IFS= read -r -d '' skill_md; do
    link_skill "$dest" "$(dirname "$skill_md")"
  done
done
