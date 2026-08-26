#!/bin/bash
# Package the workflow folder + cheatsheet.md into an installable
# "Markdown Cheatsheet.alfredworkflow" (which is just a flat zip).
# Run this before committing whenever workflow/* or cheatsheet.md change.
set -euo pipefail
cd "$(dirname "$0")"
out="Markdown Cheatsheet.alfredworkflow"

plutil -lint workflow/info.plist
chmod +x workflow/show.sh workflow/list.sh

# Smoke-test what Alfred will receive (plutil accepts JSON input), and that
# section selection actually selects — a regression to "whole file" is the
# failure mode that valid-JSON checks alone would miss.
(
  cd workflow
  export cheatsheet_file=../cheatsheet.md
  ./show.sh | plutil -convert xml1 -o /dev/null -
  section=Tables ./show.sh | tee /dev/null | plutil -convert xml1 -o /dev/null -
  section=Tables ./show.sh | grep -q '"response":"## Tables' || { echo "section extraction broken" >&2; exit 1; }
  ./list.sh | plutil -convert xml1 -o /dev/null -
  [ "$(./list.sh | grep -o '"title":' | wc -l)" -gt 2 ] || { echo "list.sh found no sections" >&2; exit 1; }
  cheatsheet_file=/nonexistent ./show.sh | plutil -convert xml1 -o /dev/null -
  cheatsheet_file=/nonexistent ./list.sh | plutil -convert xml1 -o /dev/null -
)

rm -f "$out"
zip -q -j -X "$out" workflow/info.plist workflow/icon.png workflow/lib.sh workflow/show.sh workflow/list.sh cheatsheet.md
echo "Built $out"
