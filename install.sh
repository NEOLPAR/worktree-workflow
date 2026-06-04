#!/usr/bin/env bash
#
# Installer for the worktree-workflow agent skill.
#
# Installs the skill so it is discoverable by any agent CLI that supports the
# open Agent Skills standard (SKILL.md), including GitHub Copilot CLI, Claude,
# and OpenAI Codex.
#
# It keeps a single canonical clone in
#   ~/.local/share/agent-skills/worktree-workflow
# and symlinks it into each agent's personal skills directory, so a later
# `git pull` (or re-running this script) updates every agent at once.
#
# Targets and the personal skills dir they write to:
#   copilot -> ~/.copilot/skills
#   claude  -> ~/.claude/skills
#   agents  -> ~/.agents/skills   (the USER location read by Codex, and a
#                                  generic location other agents also honor)
#
# Usage:
#   ./install.sh                 # install for copilot + claude + agents
#   ./install.sh copilot         # install for a specific target only
#   ./install.sh claude agents   # install for several targets
#   ./install.sh --copy          # copy instead of symlink
#   curl -fsSL https://raw.githubusercontent.com/NEOLPAR/worktree-workflow/main/install.sh | bash
#
set -euo pipefail

REPO_URL="https://github.com/NEOLPAR/worktree-workflow.git"
SKILL_NAME="worktree-workflow"
SRC="${XDG_DATA_HOME:-$HOME/.local/share}/agent-skills/$SKILL_NAME"

MODE="link"
TARGETS=()
for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    --link) MODE="link" ;;
    copilot|claude|agents) TARGETS+=("$arg") ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done
# Default targets if none specified.
if [ "${#TARGETS[@]}" -eq 0 ]; then
  TARGETS=(copilot claude agents)
fi

# Resolve the source of the skill. When run from inside a checkout, use it;
# otherwise clone (or update) the canonical copy.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-/dev/null}")" 2>/dev/null && pwd || true)"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/SKILL.md" ]; then
  SRC="$SCRIPT_DIR"
  echo "Using skill source: $SRC"
else
  mkdir -p "$(dirname "$SRC")"
  if [ -d "$SRC/.git" ]; then
    echo "Updating existing clone at $SRC"
    git -C "$SRC" pull --ff-only
  else
    echo "Cloning $REPO_URL -> $SRC"
    git clone --depth 1 "$REPO_URL" "$SRC"
  fi
fi

target_dir() {
  case "$1" in
    copilot) echo "$HOME/.copilot/skills" ;;
    claude)  echo "$HOME/.claude/skills" ;;
    agents)  echo "$HOME/.agents/skills" ;;
  esac
}

for t in "${TARGETS[@]}"; do
  dir="$(target_dir "$t")"
  dest="$dir/$SKILL_NAME"
  mkdir -p "$dir"
  rm -rf "$dest"
  if [ "$MODE" = "copy" ]; then
    mkdir -p "$dest"
    # Copy skill payload only (skip VCS / installer scaffolding).
    cp "$SRC/SKILL.md" "$dest/"
    [ -d "$SRC/references" ] && cp -r "$SRC/references" "$dest/"
    echo "Copied  -> $dest"
  else
    ln -sfn "$SRC" "$dest"
    echo "Linked  -> $dest -> $SRC"
  fi
done

cat <<EOF

Done.

The skill is now in your personal skills directories. Activate it:
  - Copilot CLI:  /skills reload   then  /skills info worktree-workflow
  - Claude:       restart the CLI (it auto-detects ~/.claude/skills)
  - Codex:        auto-detected from ~/.agents/skills; restart Codex if it
                  doesn't appear. List with /skills, invoke with \$worktree-workflow

Source clone: $SRC  (run 'git -C "$SRC" pull' or re-run this script to update)
EOF
