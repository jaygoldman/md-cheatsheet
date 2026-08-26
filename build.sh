#!/bin/bash
# Build the release artifact, Markdown-Cheatsheet.alfredworkflow (an
# .alfredworkflow is just a flat zip of the workflow folder + cheatsheet.md).
# It is not committed; attach it to the GitHub release for the version in
# workflow/info.plist.
set -euo pipefail
cd "$(dirname "$0")"
out="Markdown-Cheatsheet.alfredworkflow"

plutil -lint workflow/info.plist
chmod +x workflow/show.sh workflow/list.sh

# Smoke-test what Alfred will receive, in Alfred's environment (bash 3.2,
# /usr/bin tools only) rather than the developer's. plutil accepts JSON input.
run() { env -i PATH=/usr/bin:/bin HOME="$HOME" cheatsheet_file=../cheatsheet.md "$@"; }
fail() { echo "build.sh: $*" >&2; exit 1; }
(
  cd workflow
  whole=$(run ./show.sh)
  printf '%s' "$whole" | plutil -convert xml1 -o /dev/null -
  # The Alfred rewrite happened: no table separator rows, no anchor nav line,
  # no 4-backtick fence survive, and the first table became bullets.
  case "$whole" in *'\n|---'*) fail "table rows survived the rewrite";; esac
  case "$whole" in *'[Text](#text)'*) fail "anchor nav line survived the rewrite";; esac
  case "$whole" in *'\n````'*)  fail "4-backtick fence survived the rewrite";; esac
  case "$whole" in *'- *italic* — `*italic*`'*) ;; *) fail "table was not rewritten as bullets";; esac

  list=$(run ./list.sh)
  printf '%s' "$list" | plutil -convert xml1 -o /dev/null -
  titles=$(printf '%s' "$list" | grep -o '"title":"[^"]*"' | sed 's/^"title":"//; s/"$//' | grep -v '^Whole cheatsheet$')
  [ "$(printf '%s\n' "$titles" | wc -l)" -gt 2 ] || fail "list.sh found no sections"
  # Every listed section round-trips: choosing it shows exactly that section.
  while IFS= read -r t; do
    out=$(run section="$t" ./show.sh)
    printf '%s' "$out" | plutil -convert xml1 -o /dev/null -
    case "$out" in '{"response":"## '"$t"'\n'*) ;; *) fail "section '$t' did not round-trip";; esac
  done <<< "$titles"

  run cheatsheet_file=/nonexistent ./show.sh | plutil -convert xml1 -o /dev/null -
  run cheatsheet_file=/nonexistent ./list.sh | plutil -convert xml1 -o /dev/null -
)

rm -f "$out"
zip -q -j -X "$out" workflow/info.plist workflow/icon.png workflow/lib.sh workflow/show.sh workflow/list.sh cheatsheet.md
[ "$(unzip -Z -1 "$out" | wc -l)" -eq 6 ] || fail "package should have 6 entries"
unzip -Z -v "$out" show.sh list.sh | grep -q 'rwxr-xr-x' || fail "scripts lost their exec bit"
echo "Built $out (version $(plutil -extract version raw workflow/info.plist))"
