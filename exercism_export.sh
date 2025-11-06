#!/usr/bin/env bash
set -euo pipefail

# --- repo root anchor (where this script lives) ---
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

# --- args (safe with set -u) ---
SRC_DIR="${1-}"
SLUG="${2-}"

if [[ -z "$SRC_DIR" ]]; then
  echo "Error: missing source exercise folder."
  echo "Usage: $0 /path/to/exercise [slug]"
  exit 1
fi
if [[ ! -d "$SRC_DIR" ]]; then
  echo "Error: '$SRC_DIR' is not a directory."
  exit 1
fi
if [[ -z "$SLUG" ]]; then
  SLUG="$(basename "$SRC_DIR")"
fi

# --- destination inside this repo ---
DEST_DIR="${REPO_ROOT}/exercises/${SLUG}"
mkdir -p "$DEST_DIR"

# --- helper: find first non-test JS/MJS, pruning junk ---
find_first() {
  local search_dir="$1"
  # prints first match then stops
  find "$search_dir" \
    -path "$search_dir/node_modules" -prune -o \
    -path "$search_dir/.exercism"   -prune -o \
    -type f \( -name '*.js' -o -name '*.mjs' \) \
    ! -name '*test*' ! -name '*spec*' \
    ! -name 'jest.config.js' \
    ! -name 'babel.config.js' \
    ! -name 'eslint*' \
    -print -quit 2>/dev/null
}

# --- search order: root -> src/ -> lib/ ---
SOL="$(find_first "$SRC_DIR" || true)"
if [[ -z "${SOL}" && -d "$SRC_DIR/src" ]]; then
  SOL="$(find_first "$SRC_DIR/src" || true)"
fi
if [[ -z "${SOL}" && -d "$SRC_DIR/lib" ]]; then
  SOL="$(find_first "$SRC_DIR/lib" || true)"
fi

if [[ -z "${SOL}" ]]; then
  echo "Could not find a solution .js/.mjs file. Copy manually or adjust patterns."
  exit 2
fi

# --- copy, preserving extension ---
ext="${SOL##*.}"
DEST_SOL="${DEST_DIR}/solution.${ext}"
cp "$SOL" "$DEST_SOL"

# --- notes template (create if missing) ---
NOTES="${DEST_DIR}/notes.md"
if [[ ! -f "$NOTES" ]]; then
  cat > "$NOTES" <<EOF
# ${SLUG}

**Date:** $(date +%Y-%m-%d)

## Concepts learned
-

## Approach
-

## Edge cases / tests
-

## Reflection
- What was hard?
- What did I improve?
EOF
fi

# --- ensure .gitignore has sane defaults ---
GI="${REPO_ROOT}/.gitignore"
touch "$GI"
ensure_line() { grep -qxF "$1" "$GI" || echo "$1" >> "$GI"; }
ensure_line ".DS_Store"
ensure_line "node_modules/"
ensure_line ".vscode/"
ensure_line "*.log"
ensure_line ".exercism/"
ensure_line "package*.json"
ensure_line "babel.config.js"
ensure_line "jest.config.js"
ensure_line "eslint.config.*"

echo "✓ Exported:"
echo "  - ${DEST_SOL}"
echo "  - ${NOTES}"
echo
echo "Next steps:"
echo "  (cd ${REPO_ROOT} && git add ${DEST_SOL#${REPO_ROOT}/} ${NOTES#${REPO_ROOT}/} .gitignore && git commit -m \"add ${SLUG} exercise solution + notes\" && git push)"
