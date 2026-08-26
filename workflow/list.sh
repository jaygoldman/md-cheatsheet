#!/bin/bash
# Script Filter for the keyword (default "mdc", set in the Configure panel). Lists the cheatsheet's sections (plus
# "Whole cheatsheet"); Alfred filters them as you type. Each item sets the
# `section` variable, which show.sh reads to render only that section. `arg`
# carries the same name purely so Alfred treats the item as actionable.

cd "$(dirname "$0")" && source ./lib.sh || {
  printf '{"items":[{"title":"Workflow broken","subtitle":"lib.sh is missing — reinstall the workflow","valid":false}]}'
  exit 0
}

if ! have_file; then
  printf '{"items":[{"title":"Cheatsheet not found","subtitle":"%s — set “Cheatsheet file” in the workflow’s Configure panel","valid":false}]}' \
    "$(printf '%s' "$file" | json_body)"
  exit 0
fi

printf '{"items":[{"title":"Whole cheatsheet","subtitle":"Every section","arg":"","match":"all everything whole cheatsheet"}'
sections | while IFS= read -r s; do
  j=$(printf '%s' "$s" | json_body)
  printf ',{"title":"%s","subtitle":"Show only this section","arg":"%s","variables":{"section":"%s"}}' "$j" "$j" "$j"
done
printf ']}'
