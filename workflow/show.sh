#!/bin/bash
# Text View script for the Markdown Cheatsheet Alfred workflow.
#
# Alfred runs this with the workflow folder as the working directory and
# expects JSON on stdout: {"response": "<markdown>", "footer": "<text>"}.
# The Text View renders "response" as Markdown.
#
# The cheatsheet shown is, in order of preference:
#   1. $cheatsheet_file  — set in the workflow's Configure panel (a path to
#      your own copy, e.g. a clone of this repo), or
#   2. cheatsheet.md     — the copy bundled inside the workflow.

set -u -o pipefail

file="${cheatsheet_file:-cheatsheet.md}"
file="${file/#\~/$HOME}" # the picker stores absolute paths, but a typed ~ should work too

# stdin: markdown, $FOOTER: footer text → JSON on stdout. Built by hand so the
# workflow has no jq/python dependency. iconv drops any bytes that aren't valid
# UTF-8 (Alfred rejects JSON that isn't); awk escapes what JSON requires and
# strips the remaining C0 control characters, which JSON forbids unescaped.
to_json() {
  iconv -c -f UTF-8 -t UTF-8 | LC_ALL=C awk '
    function esc(s) {
      gsub(/\\/, "\\\\", s); gsub(/"/, "\\\"", s)
      gsub(/\t/, "\\t", s);  gsub(/\r/, "\\r", s)
      gsub(/[\001-\010\013\014\016-\037]/, "", s)
      return s
    }
    BEGIN { ORS = ""; printf "{\"response\":\"" }
    { print esc($0) "\\n" }
    END { printf "\",\"footer\":\"%s\"}", esc(ENVIRON["FOOTER"]) }'
}

not_found() {
  FOOTER="⎋ Close" to_json <<EOF
# Cheatsheet not found

Could not read \`$file\`.

Open the workflow's **Configure** panel and point *Cheatsheet file* at a
Markdown file, or clear it to use the bundled copy.
EOF
}

if [[ ! -f "$file" || ! -r "$file" ]]; then
  not_found
  exit 0
fi

if ! out=$(FOOTER="⎋ Close  ·  ⌘↩ Open $(basename "$file") to edit" to_json < "$file"); then
  not_found
  exit 0
fi
printf '%s' "$out"
