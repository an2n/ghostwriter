#!/usr/bin/env bash
set -euo pipefail

# Installs the ghostwriter, ai-check, and ai-clean skills into one or more
# agent harnesses' skills directories.
#
# Usage:
#   ./install.sh            # Claude Code only (~/.claude/skills)
#   ./install.sh claude     # same as above
#   ./install.sh codex      # Codex CLI (~/.codex/skills)
#   ./install.sh chatgpt    # ChatGPT desktop / other agents (~/.agents/skills)
#   ./install.sh all        # all of the above
#   ./install.sh --copy     # copy files instead of symlinking (any target above)
#
# Symlinks are used by default so a `git pull` in this repo updates the
# installed skills automatically. Pass --copy for a self-contained install
# that doesn't depend on this repo staying in place.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
COPY=false
TARGETS=()

for arg in "$@"; do
  case "$arg" in
    --copy) COPY=true ;;
    claude|codex|chatgpt|all) TARGETS+=("$arg") ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

if [ ${#TARGETS[@]} -eq 0 ]; then
  TARGETS=("claude")
fi

install_to() {
  local dest_root="$1"
  mkdir -p "$dest_root"
  for skill_dir in "$SKILLS_SRC"/*/; do
    local name
    name="$(basename "$skill_dir")"
    local dest="$dest_root/$name"
    rm -rf "$dest"
    if [ "$COPY" = true ]; then
      cp -r "$skill_dir" "$dest"
    else
      ln -s "$skill_dir" "$dest"
    fi
    echo "  $name -> $dest"
  done
}

for target in "${TARGETS[@]}"; do
  case "$target" in
    claude)
      echo "Installing to Claude Code (~/.claude/skills) - also picked up by OpenCode:"
      install_to "$HOME/.claude/skills"
      ;;
    codex)
      echo "Installing to Codex CLI (~/.codex/skills):"
      install_to "$HOME/.codex/skills"
      ;;
    chatgpt)
      echo "Installing to ChatGPT desktop / other agents (~/.agents/skills):"
      install_to "$HOME/.agents/skills"
      ;;
    all)
      echo "Installing to Claude Code (~/.claude/skills) - also picked up by OpenCode:"
      install_to "$HOME/.claude/skills"
      echo "Installing to Codex CLI (~/.codex/skills):"
      install_to "$HOME/.codex/skills"
      echo "Installing to ChatGPT desktop / other agents (~/.agents/skills):"
      install_to "$HOME/.agents/skills"
      ;;
  esac
done

echo "Done. Restart your agent/session for the skills to be picked up."
