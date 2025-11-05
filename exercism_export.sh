#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./exercism_export.sh /path/to/exercise [slug]
# Example:
#   ./exercism_export.sh ~/Exercism/javascript/vehicle-purchase vehicle-purchase

SRC_DIR="${1:-}"
SLUG="${2:-}"

if [[ -z "${SRC_DIR}" ]]; then
  echo "Error: missing source exercise folder."
  echo "Usage: ./exercism_export.sh /path/to/exercise [slug]"
  exit 1
fi

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "Error: '${SRC_DIR}' is not a directory."
  exit 1
fi

if [[ -z "${SLUG}" ]]; then
  SLUG="$(basename "$SRC_DIR")"
fi

DEST_DIR="exercises/${SLUG}"
mkdir -p "${DEST_DIR}"

# find_first SOL: set SOL to the first matching file path (if any)
find_first() {
  local search_dir="$1"
  local SOL_LOCAL=""
  # prune node_modules and .exercism; match .js or .mjs; exclude tests/configs
  while IFS= read -r -d '' f; do
    SOL_LOCAL="$f"
    break
  done < <(find "$search_dir" \
      -path "$search_dir/node_modules" -prune -o \
      -path "$search_dir/.exercism"   -prune -o \
      -type f \( -name '*.js' -o -name '*.mjs' \) \
      ! -name '*test*' ! -name '*spec*' \
      ! -name 'jest.config.js' \
      ! -name 'babel.config.js' \
      ! -name 'eslint*' \
      -print0 2>/dev/null)
  echo "$SOL_LOCAL"
}

SOL=""

# 1) look in exercise root (maxdepth 1)
SOL="$(find_first "$SRC_DIR")"

# 2) fallback to src/
if [[ -z "$SOL" && -d "$SRC_DIR/src" ]]; then
  SOL="$(find_first "$SRC_DIR/src")"
fi

# 3) fallback to lib/
if [[ -z "$SOL" && -d "$SRC_DIR/lib" ]]; then
  SOL="$(find_first "$SRC_DIR/lib")"
fi

if [[ -z "$SOL" ]]; then
  echo "Could not find a solution .js/.mjs file. Copy manually or adjust patterns."
  exit 2
fi

# preserve extension
ext="${SOL##*.}"
DEST_SOL="${DEST_DIR}/solution.${ext}"
cp "$SOL" "$DEST_SOL"

# notes template
NOTES="${DEST_DIR}/notes.md"
if [[ ! -f "$NOTES" ]]; then
  cat > "$NOTES" <<NOTES_EOF
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
NOTES_EOF
fi

# Ensure a minimal .gitignore exists (append if missing)
if [[ ! -f ".gitignore" ]]; then
  touch .gitignore
fi

ensure_line() {
  local line="$1"
  grep -qxF "$line" .gitignore || echo "$line" >> .gitignore
}

# OS / tools
ensure_line ".DS_Store"
ensure_line "node_modules/"
ensure_line ".vscode/"
ensure_line "*.log"

# Exercism artifacts & configs
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
echo "  git add ${DEST_SOL} ${NOTES} .gitignore"
echo "  git commit -m \"add ${SLUG} exercise solution + notes\""
echo "  git push"
