#!/usr/bin/env bash
set -euo pipefail

version="$1"
changelog="${2:-CHANGELOG.md}"

output=$(awk -v ver="[$version]" '
  index($0, "## " ver) == 1 { in_section = 1; next }
  in_section && /^## \[/ { exit }
  in_section && NF == 0 && !has_content { next }
  in_section { has_content = 1; print }
' "$changelog")

if [ -z "$output" ]; then
  echo "Error: No changelog section found for version $version in $changelog" >&2
  exit 1
fi

echo "$output"
