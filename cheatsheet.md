# Markdown cheatsheet

[Text](#text) · [Headings](#headings) · [Lists](#lists) · [Code](#code) · [Links & images](#links--images) · [Tables](#tables) · [Misc](#misc) · [More text & lists](#more-text--lists) · [More links & images](#more-links--images) · [More tables](#more-tables) · [HTML fallbacks](#html-fallbacks) · [GitHub flavoured](#github-flavoured) · [Obsidian, Notion & static sites](#obsidian-notion--static-sites)

## Text

| Format | Syntax |
|---|---|
| *italic* | `*italic*` or `_italic_` |
| **bold** | `**bold**` |
| ***bold italic*** | `***bold italic***` |
| ~~strikethrough~~ | `~~strikethrough~~` |
| `inline code` | `` `inline code` `` |
| H~2~O (subscript) | `H~2~O` |
| X^2^ (superscript) | `X^2^` |

> Blockquote: prefix lines with `>`

## Headings

```markdown
# H1     #### H4
## H2    ##### H5
### H3   ###### H6
```

Heading ID: `### Heading {#custom-id}` — link to it with `[text](#custom-id)`

## Lists

```markdown
- Bullet          1. Numbered
  - Nested          2. Item
- [ ] Task            - nested needs 3 spaces
- [x] Done
```

Definition list: `Term` on one line, `: Definition` on the next

## Code

````
```python          ← fenced block with language
def hi(): pass
```
    indented block (4 spaces) also works
````

Escape a backtick with a backslash: `` \` `` — or wrap in double backticks.

## Links & images

| Result | Syntax |
|---|---|
| [text](https://example.com) | `[text](https://example.com)` |
| hover title | `[text](url "title")` |
| <https://example.com> | `<https://example.com>` |
| image | `![alt](img.png "title")` |
| reference link | `[ref][1]` + `[1]: url` |

## Tables

```markdown
| Left | Centre | Right |
|:-----|:------:|------:|
| a    | b      | c     |
```

| Left | Centre | Right |
|:-----|:------:|------:|
| a    | b      | c     |

## Misc

| What | Syntax |
|---|---|
| Horizontal rule | `---` or `***` |
| Line break | two trailing spaces, or `\` at line end |
| Escape character | `\*not italic\*` |
| Footnote | `text[^1]` then `[^1]: note` |
| HTML inline | `<kbd>⌘</kbd> works` |

## More text & lists

| What | Syntax |
|---|---|
| Highlight *(extended)* | `==marked==` |
| Ordered list starting at N | `3. item` |
| Number at line start, not a list | `1986\. A great year` |
| Nested blockquote | `> > nested` |
| List inside a blockquote | `> - item` |
| Paragraph inside a list item | indent to the item's text (2 spaces after `- `, 3 after `1. `) |
| Code block inside a list item | a fenced block at that same indent, or indent 8 spaces |
| Setext headings | `Title` + `=====` (H1) / `-----` (H2) underline |
| Escapable characters | `` \ ` * _ { } [ ] ( ) # + - . ! \| `` |

## More links & images

| What | Syntax |
|---|---|
| Clickable image | `[![alt](img.png)](https://url)` |
| URL with spaces | `[text](<my file.md>)` |
| Link to a heading | `[text](#my-heading)` — lowercase, spaces → `-`, punctuation dropped |
| Image with size *(HTML)* | `<img src="x.png" width="200">` |

## More tables

| What | Syntax |
|---|---|
| Pipe inside a cell | `&#124;`, or put a backslash before the pipe |
| Line break inside a cell | `<br>` |
| Formatting in cells | `**bold**`, `` `code` `` and links work; multi-line cells don't |

## HTML fallbacks

Work in most renderers, including ones without the pandoc extensions above.

| What | Syntax |
|---|---|
| Subscript / superscript | `H<sub>2</sub>O` · `X<sup>2</sup>` |
| Collapsible section | `<details><summary>Title</summary>…</details>` |
| Hidden comment | `<!-- not rendered -->` |
| Centre / align | `<p align="center">…</p>` |

## GitHub flavoured

| What | Syntax |
|---|---|
| Alerts | `> [!NOTE]` · `[!TIP]` · `[!IMPORTANT]` · `[!WARNING]` · `[!CAUTION]` |
| Auto-links | `#123` issue/PR · `@user` · commit SHA |
| Emoji | `:tada:` |
| Diff block | ```` ```diff ```` with `+` / `-` lines |
| Mermaid diagram | ```` ```mermaid ```` |
| Math | `$E=mc^2$` inline · `$$…$$` block |

## Obsidian, Notion & static sites

| What | Syntax |
|---|---|
| Wiki link | `[[Note name]]` · `[[Note#Heading]]` · `[[Note\|alias]]` |
| Embed | `![[Note]]` |
| YAML front matter | `---` / `title: x` / `---` at the top of the file |
| Abbreviation *(Markdown Extra, kramdown)* | `*[HTML]: HyperText Markup Language` |
| Table of contents | `[TOC]` (Python-Markdown / MkDocs, Typora) · `{{TOC}}` (MultiMarkdown) |
