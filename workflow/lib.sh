# shellcheck shell=bash
# Shared by show.sh and list.sh. Sourced, not executed.
#
# Alfred runs the workflow's scripts with the workflow folder as the working
# directory. The cheatsheet shown is, in order of preference:
#   1. $cheatsheet_file  — set in the workflow's Configure panel (a path to
#      your own copy, e.g. a clone of this repo), or
#   2. cheatsheet.md     — the copy bundled inside the workflow.

set -u -o pipefail

file="${cheatsheet_file:-cheatsheet.md}"
file="${file/#\~/${HOME:-}}" # the picker stores absolute paths, but a typed ~ should work too

# Is $file a readable regular file?
have_file() { [[ -f "$file" && -r "$file" ]]; }

# stdin: text → a JSON string *body* (no surrounding quotes) on stdout. Built
# by hand so the workflow has no jq/python dependency. iconv drops any bytes
# that aren't valid UTF-8 (Alfred rejects JSON that isn't); awk escapes what
# JSON requires and strips the remaining C0 control characters, which JSON
# forbids unescaped. Lines are joined with \n.
json_body() {
  iconv -c -f UTF-8 -t UTF-8 | LC_ALL=C awk '
    BEGIN { ORS = "" }
    {
      gsub(/\\/, "\\\\"); gsub(/"/, "\\\"")
      gsub(/\t/, "\\t");  gsub(/\r/, "\\r")
      gsub(/[\001-\010\013\014\016-\037]/, "")
      if (NR > 1) print "\\n"
      print
    }'
}

# The one place that understands the cheatsheet's structure.
#   headings ""      → prints every "## " heading name, one per line
#   headings "Name"  → prints that section (heading through the line before the
#                      next "## "), first match wins; exit status 1 if no match
# Matching is literal and case-insensitive; the name travels via the
# environment so nothing (awk -v, grep) re-interprets backslashes or regex
# characters in it. Headings inside fenced code blocks are ignored: a fence
# (``` or ~~~, up to 3 spaces indented) is closed only by a run of the same
# character at least as long, per CommonMark. Names are trimmed of trailing
# whitespace, closing #s and CR.
headings() {
  want="$1" LC_ALL=C awk '
    function name(s) {
      s = substr(s, 4); sub(/\r$/, "", s); sub(/[ \t]+$/, "", s)
      sub(/[ \t]+#+$/, "", s); sub(/[ \t]+$/, "", s); return s
    }
    function fence_marker(s,   m) {          # "```"/"~~~~" at line start, or ""
      if (!match(s, /^ {0,3}(`{3,}|~{3,})/)) return ""
      m = substr(s, RSTART, RLENGTH); sub(/^ +/, "", m); return m
    }
    BEGIN { want = tolower(ENVIRON["want"]) }
    {
      m = fence_marker($0)
      if (!fence && m != "") {
        fence = 1; fchar = substr(m, 1, 1); flen = length(m)
      } else if (fence && m != "" && substr(m, 1, 1) == fchar && length(m) >= flen && $0 ~ /^[ \t`~]+$/) {
        fence = 0
      } else if (!fence && /^## /) {
        n = name($0)
        if (n == "") next
        if (want == "") { print n; next }
        if (on) exit                          # end of the wanted section
        on = (tolower(n) == want); if (on) found = 1
      }
    }
    want != "" && on { print }
    END { if (want != "") exit !found }
  ' "$file"
}
sections()     { headings ""; }
section_text() { headings "$1"; }

# Rewrite Markdown that Alfred'\''s Text View can'\''t render into things it can:
#  - the nav line of [Section](#anchor) links near the top is dropped
#    (the renderer doesn'\''t follow in-document anchors)
#  - tables become bullet lists, "- cell — cell — cell", header and separator
#    rows dropped (the renderer doesn'\''t do tables)
#  - fences opened with 4+ backticks become indented code blocks (the renderer
#    doesn'\''t do nested fences)
for_alfred() {
  LC_ALL=C awk '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    /^````/ { inbig = !inbig; next }
    inbig   { print "    " $0; next }
    /^```/  { infence = !infence; print; next }
    infence { print; next }
    NR <= 4 && /^\[[^]]*\]\(#/ && /\)$/ { skipblank = 1; next }
    skipblank && /^$/ { skipblank = 0; next }
    { skipblank = 0 }
    /^\|/ {
      line = $0
      gsub(/\\\|/, "\001", line)                      # protect escaped pipes
      sub(/^\|/, "", line); sub(/\|[ \t]*$/, "", line)
      n = split(line, c, "|")
      if (n >= 1 && trim(c[1]) ~ /^:?-+:?$/) next   # separator row
      if (!intable) { intable = 1; next }            # header row
      out = ""
      for (i = 1; i <= n; i++) { cell = trim(c[i]); gsub(/\001/, "|", cell); out = out (i > 1 ? " — " : "") cell }
      print "- " out
      next
    }
    { intable = 0; print }
  '
}
