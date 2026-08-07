# Ch 2: Self-contained HTML

The whole discipline: **one file, opens by double-click, renders with no internet.** Everything below serves that.

## Structure
- A single `.html` file. Inline all CSS in one `<style>` block and all JS in one `<script>` block. No external stylesheets, no CDN scripts, no web-font URLs.
- Embed assets as `data:` URIs - images as base64, small fonts inline. If an asset is too big to inline comfortably, reconsider whether it's needed.
- Start from a minimal reset (`*{box-sizing:border-box} body{margin:0}`) so it looks the same everywhere.

## Layout and responsiveness
- Use relative units and flexbox/grid; set `max-width:100%` on media.
- The page body must never scroll sideways. Wide content - tables, code, diagrams - goes inside its own `overflow-x:auto` container that scrolls independently.
- Test at a narrow width (~390px) and a wide one; no horizontal overflow at either.

## Light and dark
Unless the piece deliberately commits to one look, style both. Default with `@media (prefers-color-scheme: dark)`, and drive colors through CSS custom properties so there is one place to switch them. Check contrast in both.

## Typography and hierarchy
- One type scale, a small set of sizes. Big numbers for the thing that matters; quiet labels around them.
- Generous whitespace. Let sections breathe - a cramped page reads as noise.

## Interactivity (only if it earns its place)
- Vanilla JS, no framework. Sliders, toggles, and sortable tables cover most artifacts.
- Every control needs an immediate, visible effect. If a control doesn't change what's on screen, cut it.
- Keep state in the page; nothing persists, nothing phones home.

## Print-friendliness
Even an HTML-first artifact should print cleanly (it is the PDF path - Ch 4). Add a print stylesheet: hide interactive chrome, set sane page margins, and keep a chart or table row from breaking across pages.

## The check before you ship
- Opens from `file://` with the network off and renders fully.
- No console errors, no missing assets.
- No horizontal page scroll at narrow or wide widths.
- Readable in light and dark.
- Prints without clipping.
