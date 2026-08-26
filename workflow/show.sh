#!/bin/bash
# Text View script. Prints {"response": "<markdown>", "footer": "<text>"};
# the Text View renders "response" as Markdown.
#
# With no $section the whole cheatsheet is shown (the ⌃⌥M hotkey, or keyword ⏎).
# The keyword's Script Filter (list.sh) sets the `section` variable on each item so
# only that section is shown. Deliberately not argv: the hotkey would hand us
# the macOS selection as $1.

cd "$(dirname "$0")" && source ./lib.sh || {
  printf '{"response":"# Workflow broken\\n\\n`lib.sh` is missing — reinstall the workflow.","footer":"⎋ Close"}'
  exit 0
}
section="${section:-}"

# A function rather than a heredoc inside "$( … )": bash 3.2 (Alfred's
# /bin/bash) mis-parses the apostrophe in "workflow's" inside $( ).
not_found_md() {
  cat <<EOF
# Cheatsheet not found

Could not read \`$file\`.

Open the workflow's **Configure** panel and point *Cheatsheet file* at a
Markdown file, or clear it to use the bundled copy.
EOF
}

if ! have_file; then
  printf '{"response":"%s","footer":"⎋ Close"}' "$(not_found_md | json_body)"
  exit 0
fi

name=$(basename -- "$file")
if [[ -n "$section" ]] && text=$(section_text "$section"); then
  footer="⎋ Close  ·  ⌘↩ Open $name to edit  ·  “${keyword:-mdc}” for other sections"
else
  text=$(cat < "$file")           # unknown or empty section: whole cheatsheet
  footer="⎋ Close  ·  ⌘↩ Open $name to edit"
fi

if ! body=$(printf '%s\n' "$text" | for_alfred | json_body); then
  printf '{"response":"%s","footer":"⎋ Close"}' "$(not_found_md | json_body)"
  exit 0
fi
printf '{"response":"%s","footer":"%s"}' "$body" "$(printf '%s' "$footer" | json_body)"
