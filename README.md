# Markdown cheatsheet popup — Alfred edition

A system-wide Markdown cheatsheet popup for macOS, as an [Alfred](https://www.alfredapp.com)
workflow. Press **⌃⌥M** anywhere to instantly show a floating window with a
rendered Markdown cheatsheet; press **Esc** to dismiss it. Type **`md`** into
Alfred to jump straight to one section (`md tables`), and **⌘↩** opens the
cheatsheet file so you can edit it.

This is a port of [Aaron Schiff's md-cheatsheet](https://github.com/aaronschiff/md-cheatsheet),
which does the same thing with Hammerspoon + pandoc. The idea and the core
cheatsheet content are his; this fork swaps the Hammerspoon/pandoc/Lua
implementation for Alfred's built-in Markdown
[Text View](https://www.alfredapp.com/help/workflows/user-interface/text/), so
there is nothing to install besides Alfred, and adds section navigation and
more content.

## Installation

Requires macOS and Alfred 5.5 or later with the
[Powerpack](https://www.alfredapp.com/powerpack/) (workflows need it).

1. Download [`Markdown Cheatsheet.alfredworkflow`](https://github.com/jaygoldman/md-cheatsheet/raw/main/Markdown%20Cheatsheet.alfredworkflow).
2. Double-click it; Alfred will ask to import it.
3. Press **⌃⌥M**, or type `md` into Alfred.

If ⌃⌥M clashes with something else on your Mac, open the workflow in Alfred
Preferences and change the hotkey on the leftmost (Hotkey) object.

## Usage

| Key | Action |
|---|---|
| ⌃⌥M (anywhere) | Show the whole cheatsheet |
| `md` ⏎ (in Alfred) | Show the whole cheatsheet |
| `md tables` (in Alfred) | List matching sections; ⏎ shows just that section |
| Esc | Close the popup |
| ⌘↩ (in the popup) | Open the cheatsheet file in your default Markdown editor |

The section list is built from the `## ` headings in the cheatsheet, so any
section you add to the file shows up in `md` automatically.

The top of the cheatsheet also has a row of `[Section](#section)` links for
when the file is viewed on GitHub or in a Markdown editor. Alfred's Text View
doesn't follow in-document anchors (they'd just show as literal text), so the
workflow strips that line for the popup — `md <section>` is the Alfred-native
way to jump.

## Customising the cheatsheet

The workflow ships with a copy of `cheatsheet.md` inside it, and that is what
⌘↩ opens by default. Edits to that copy work, but are lost if you reinstall
the workflow.

To keep your own copy as the source of truth instead, clone this repo (or put
a Markdown file anywhere you like) and point the workflow at it: open the
workflow in Alfred Preferences, click **Configure Workflow…**, and set
**Cheatsheet file**. Leave it empty to go back to the bundled copy.

```sh
git clone https://github.com/jaygoldman/md-cheatsheet.git ~/md-cheatsheet
# then set "Cheatsheet file" to ~/md-cheatsheet/cheatsheet.md
```

Browse to the file or type the path (`~` is fine). The file is re-read every
time the popup opens, so edits show up immediately. Sections are whatever you
put under `## ` headings; keep the ones you use most at the top.

## What's in the cheatsheet

The original sections (Text, Headings, Lists, Code, Links & images, Tables,
Misc) are Aaron's, checked against
[markdownguide.org](https://www.markdownguide.org/cheat-sheet/). This fork
appends, in roughly descending order of how often you'll need them:

- **More text & lists** — highlight, ordered lists starting at N, escaping a
  leading number, nested blockquotes, lists in quotes, paragraphs inside list
  items, setext headings, the commonly escaped characters.
- **More links & images** — clickable images, URLs with spaces, links to
  headings, sized images.
- **More tables** — pipes and line breaks inside cells, what formatting works
  in cells.
- **HTML fallbacks** — sub/superscript, collapsible sections, hidden comments,
  alignment; these work in renderers that lack the pandoc extensions.
- **GitHub flavoured** — alerts (`> [!NOTE]`), auto-links, emoji shortcodes,
  diff and Mermaid fences, math.
- **Obsidian, Notion & static sites** — wiki links, embeds, YAML front matter,
  abbreviations, `[TOC]`.

## How it works

- `workflow/info.plist` — the workflow. A Hotkey trigger (⌃⌥M) and an `md`
  Script Filter both feed a **Text View** object in Markdown mode. A ⌘↩
  connection from the Text View runs `open` on the cheatsheet file.
- `workflow/lib.sh` — shared helpers: resolves which file to show
  (`$cheatsheet_file` from the Configure panel, else the bundled
  `cheatsheet.md`), JSON-escapes text with `awk`, lists the `## ` headings
  (ignoring any inside fenced code blocks) and extracts one section, and
  rewrites the Markdown for Alfred's renderer — tables become bullet lists
  (`- format — syntax`), 4-backtick fences become indented code blocks, and
  the anchor-link nav line is dropped. `cheatsheet.md` itself stays plain
  GitHub-flavoured Markdown.
- `workflow/list.sh` — the Script Filter. Emits Alfred's items JSON: "Whole
  cheatsheet" plus one item per section; Alfred filters them as you type.
- `workflow/show.sh` — the Text View's script. Prints
  `{"response": <markdown>, "footer": …}` for the whole file or the chosen
  section. Plain bash + awk + iconv, so there are no dependencies. If the file
  can't be read, the popup says so instead of showing nothing.
- `cheatsheet.md` — the content. Kept at the repo root so it stays the source
  of truth; `build.sh` copies it into the workflow package.
- `build.sh` — lints the plist, smoke-tests the scripts, and zips
  `info.plist`, `icon.png`, `lib.sh`, `show.sh`, `list.sh` and `cheatsheet.md`
  into `Markdown Cheatsheet.alfredworkflow` (an `.alfredworkflow` is just a
  flat zip). Re-run it before committing whenever those files change — the
  committed package is what the install link serves.

## Differences from the original

- **No pandoc, no Hammerspoon, no Accessibility permission.** Alfred renders
  the Markdown itself.
- **Esc closes; the hotkey doesn't toggle.** Alfred's Text View is an Alfred
  window, so pressing ⌃⌥M again re-shows it rather than dismissing it.
  Clicking outside still dismisses it unless you've turned off Alfred's
  "hide on focus loss" setting.
- **Section navigation** via `md <section>`, which the original didn't have.
- **Renderer.** Alfred's Markdown renderer is not pandoc. It handles
  headings, emphasis, inline code, code blocks, lists and blockquotes, but
  not tables, HTML, in-document anchor links or nested code fences — so
  `show.sh` rewrites tables as bullet lists and nested fences as indented
  blocks before handing the text to Alfred. A few pandoc-only extensions the
  original content demonstrates (subscript `H~2~O`, superscript `X^2^`,
  heading IDs, definition lists, footnotes) show their raw syntax in the
  rendered column. The syntax column is still correct — that's the point of a
  cheatsheet — and the **HTML fallbacks** section gives portable alternatives.
- **Light/dark** follows Alfred's theme instead of a custom CSS block.

## Building from source

```sh
git clone https://github.com/jaygoldman/md-cheatsheet.git
cd md-cheatsheet
./build.sh          # → "Markdown Cheatsheet.alfredworkflow"
open "Markdown Cheatsheet.alfredworkflow"
```

## Credits

- [Aaron Schiff](https://github.com/aaronschiff) — the original
  [md-cheatsheet](https://github.com/aaronschiff/md-cheatsheet): the concept,
  the core `cheatsheet.md`, and the Hammerspoon implementation this replaces.
- The cheatsheet content was checked against
  [markdownguide.org](https://www.markdownguide.org/cheat-sheet/).
- The icon is the "M↓" Markdown mark by Dustin Curtis
  ([dcurt.is/the-markdown-mark](https://dcurt.is/the-markdown-mark), CC0).
