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

# awk functions shared by the two Markdown-aware programs below. Fenced code
# blocks per CommonMark: ``` or ~~~ (up to 3 spaces indented) opens a fence
# that is closed only by a run of the same character at least as long.
# track_fence(line) updates the fence/fchar/flen state and returns 1 if the
# line is itself a fence marker (opening or closing).
awk_fences='
  function fence_marker(s,   m) {
    if (!match(s, /^ ? ? ?(```+|~~~+)/)) return ""
    m = substr(s, RSTART, RLENGTH); sub(/^ +/, "", m); return m
  }
  function track_fence(s,   m) {
    m = fence_marker(s)
    if (!fence && m != "") { fence = 1; fchar = substr(m, 1, 1); flen = length(m); return 1 }
    if (fence && m != "" && substr(m, 1, 1) == fchar && length(m) >= flen && s ~ /^[ \t`~]+$/) { fence = 0; return 1 }
    return 0
  }
'

# The one place that understands the cheatsheet's sections.
#   headings ""      → prints every "## " heading name, one per line
#   headings "Name"  → prints that section (heading through the line before the
#                      next "## "), first match wins; exit status 1 if no match
# Matching is literal and case-insensitive; the name travels via the
# environment so nothing (awk -v, grep) re-interprets backslashes or regex
# characters in it. Headings inside fenced code blocks are ignored. Names are
# trimmed of surrounding whitespace, closing #s and CR.
headings() {
  want="$1" LC_ALL=C awk "$awk_fences"'
    function name(s) {
      s = substr(s, 4); sub(/[ \t]+$/, "", s); sub(/[ \t]+#+$/, "", s)
      sub(/[ \t]+$/, "", s); sub(/^[ \t]+/, "", s); return s
    }
    BEGIN { want = tolower(ENVIRON["want"]) }
    { sub(/\r$/, "") }
    {
      if (track_fence($0)) { }
      else if (!fence && /^## /) {
        n = name($0)
        if (n == "") next
        if (want == "") { print n; next }
        if (on) exit                          # end of the wanted section
        on = (tolower(n) == want); if (on) found = 1
      }
    }
    want != "" && on { print }
    END { if (want != "") exit !found }
  ' < "$file"
}
sections()     { headings ""; }
section_text() { headings "$1"; }

# Rewrite Markdown that Alfred's Text View can't render into things it can
# (stdin → stdout):
#  - tables become bullet lists, "- cell — cell — cell"; the separator row is
#    dropped, and so is the header row unless the table has 3+ columns, where
#    it survives as a bold bullet (the renderer doesn't do tables)
#  - a line consisting only of [text](#anchor) links, e.g. the nav row at the
#    top of cheatsheet.md, is dropped (the renderer doesn't follow anchors)
#  - fences opened with 4+ backticks become indented code blocks (the renderer
#    doesn't do nested fences)
for_alfred() {
  LC_ALL=C awk "$awk_fences"'
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    { sub(/\r$/, ""); gsub(/[\001-\010\013\014\016-\037]/, "") }   # C0 controls never render; \001 is our placeholder below
    {
      was = fence
      if (track_fence($0)) {
        intable = 0
        if (!was) big = (fchar == "`" && flen >= 4)   # opening marker
        if (!big) print
        if (was) big = 0                              # closing marker
        next
      }
      if (fence) { print (big ? "    " : "") $0; next }
    }
    /^(\[[^]]*\]\(#[^)]*\)[ \t·|—–-]*)+$/ { skipblank = 1; next }
    skipblank && /^$/ { skipblank = 0; next }
    { skipblank = 0 }
    /^\|/ {
      line = $0
      gsub(/\\\|/, "\001", line)                      # protect escaped pipes
      sub(/^\|/, "", line); sub(/\|[ \t]*$/, "", line)
      n = split(line, c, "|")
      if (n >= 1 && trim(c[1]) ~ /^:?-+:?$/) next   # separator row
      header = !intable; intable = 1
      if (header && n <= 2) next
      out = ""
      for (i = 1; i <= n; i++) {
        cell = trim(c[i]); gsub(/\001/, "|", cell)
        if (header && cell != "") cell = "**" cell "**"
        out = out (i > 1 ? " — " : "") cell
      }
      print "- " out
      next
    }
    { intable = 0; print }
  '
}
