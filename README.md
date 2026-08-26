# Markdown cheatsheet popup — Alfred edition

A system-wide Markdown cheatsheet popup for macOS, as an [Alfred](https://www.alfredapp.com)
workflow. Press **⌃⌥M** anywhere (or type **`md`** into Alfred) to instantly
show a floating window with a rendered Markdown cheatsheet; press **Esc** to
dismiss it. **⌘↩** opens the cheatsheet file so you can edit it.

This is a port of [Aaron Schiff's md-cheatsheet](https://github.com/aaronschiff/md-cheatsheet),
which does the same thing with Hammerspoon + pandoc. The idea and the
cheatsheet content are his; this fork swaps the Hammerspoon/pandoc/Lua
implementation for Alfred's built-in Markdown [Text View](https://www.alfredapp.com/help/workflows/user-interface/text/),
so there is nothing to install besides Alfred itself.

## Installation

Requires macOS and Alfred 5.5 or later with the
[Powerpack](https://www.alfredapp.com/powerpack/) (workflows need it).

1. Download [`Markdown Cheatsheet.alfredworkflow`](https://github.com/jaygoldman/md-cheatsheet/raw/main/Markdown%20Cheatsheet.alfredworkflow).
2. Double-click it; Alfred will ask to import it.
3. Press **⌃⌥M** or type `md` into Alfred.

If ⌃⌥M clashes with something else on your Mac, open the workflow in Alfred
Preferences and change the hotkey on the leftmost (Hotkey) object.

## Usage

| Key | Action |
|---|---|
| ⌃⌥M (anywhere) | Show the cheatsheet |
| `md` (in Alfred) | Show the cheatsheet |
| Esc | Close it |
| ⌘↩ | Open the cheatsheet file in your default Markdown editor |

## Customising the cheatsheet

The workflow ships with a copy of `cheatsheet.md` inside it, and that is what
⌘↩ opens by default. Edits to that copy work, but are lost if you reinstall
the workflow.

To keep your own copy as the source of truth instead, clone this repo (or
put a Markdown file anywhere you like) and point the workflow at it: open the
workflow in Alfred Preferences, click **Configure Workflow…**, and set
**Cheatsheet file**. Leave it empty to go back to the bundled copy.

```sh
git clone https://github.com/jaygoldman/md-cheatsheet.git ~/md-cheatsheet
# then set "Cheatsheet file" to ~/md-cheatsheet/cheatsheet.md
```

Browse to the file or type the path (`~` is fine). The file is re-read every
time the popup opens, so edits show up immediately.

## How it works

- `workflow/info.plist` — the workflow: a Hotkey trigger (⌃⌥M) and a Keyword
  (`md`) both feed a **Text View** object in Markdown mode. A ⌘↩ connection
  from the Text View runs `open` on the cheatsheet file.
- `workflow/show.sh` — the Text View's script. It reads `$cheatsheet_file`
  (the Configure-panel setting) or the bundled `cheatsheet.md`, JSON-escapes it
  with `awk`, and prints the `{"response": …, "footer": …}` JSON the Text View
  expects. Plain bash + awk + iconv, so there are no dependencies. If the file
  can't be read, the popup says so instead of showing nothing.
- `cheatsheet.md` — the content. Kept at the repo root so it stays the source
  of truth; `build.sh` copies it into the workflow package.
- `build.sh` — lints the plist, smoke-tests `show.sh`, and zips `info.plist`,
  `icon.png`, `show.sh` and `cheatsheet.md` into
  `Markdown Cheatsheet.alfredworkflow` (an `.alfredworkflow` is just a flat
  zip). Re-run it before committing whenever those files change — the
  committed package is what the install link serves.

## Differences from the original

- **No pandoc, no Hammerspoon, no Accessibility permission.** Alfred renders
  the Markdown itself.
- **Esc closes; the hotkey doesn't toggle.** Alfred's Text View is an Alfred
  window, so pressing ⌃⌥M again re-shows it rather than dismissing it.
  Clicking outside still dismisses it unless you've turned off Alfred's
  "hide on focus loss" setting.
- **Renderer.** Alfred's Markdown renderer is not pandoc. The cheatsheet
  tables and code blocks render fine, but a few pandoc-only extensions the
  original content demonstrates (subscript `H~2~O`, superscript `X^2^`,
  heading IDs, definition lists, footnotes) show their raw syntax in the
  rendered column. The syntax column is still correct — that's the point of
  a cheatsheet.
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
  [md-cheatsheet](https://github.com/aaronschiff/md-cheatsheet) (concept,
  `cheatsheet.md`, and the Hammerspoon implementation this replaces).
- The cheatsheet content was checked against
  [markdownguide.org](https://www.markdownguide.org/cheat-sheet/).
- The icon is the "M↓" Markdown mark by Dustin Curtis
  ([dcurt.is/the-markdown-mark](https://dcurt.is/the-markdown-mark), CC0).
