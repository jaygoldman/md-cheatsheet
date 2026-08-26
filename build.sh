#!/bin/bash
# Package the workflow folder + cheatsheet.md into an installable
# "Markdown Cheatsheet.alfredworkflow" (which is just a flat zip).
# Run this before committing whenever workflow/* or cheatsheet.md change.
set -euo pipefail
cd "$(dirname "$0")"
out="Markdown Cheatsheet.alfredworkflow"

plutil -lint workflow/info.plist
chmod +x workflow/show.sh
# Smoke-test the JSON the Text View will receive (plutil accepts JSON input).
(cd workflow && cheatsheet_file=../cheatsheet.md ./show.sh | plutil -convert xml1 -o /dev/null -)

rm -f "$out"
zip -q -j -X "$out" workflow/info.plist workflow/icon.png workflow/show.sh cheatsheet.md
echo "Built $out"
