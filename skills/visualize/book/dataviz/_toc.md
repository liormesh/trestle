# Data & Document Visualization

How to turn plans, reports, data, and explanations into clear visual artifacts - self-contained HTML or PDF. Read this `_toc.md` first, then load only the chapters you need (each carries a "use when" hint). Paired with the `/visualize` skill.

## Chapters
- [Ch 1: When to visualize, and which format](ch01-when-and-format.md) - *Use when: deciding whether a visual beats markdown, and whether to make HTML or PDF*
- [Ch 2: Self-contained HTML](ch02-self-contained-html.md) - *Use when: building any HTML artifact (always)*
- [Ch 3: Charts and data](ch03-charts-and-data.md) - *Use when: the artifact shows numbers, metrics, or comparisons*
- [Ch 4: PDF output](ch04-pdf-output.md) - *Use when: the deliverable has to be a PDF*
- [Ch 5: Gotchas](ch05-gotchas.md) - *Use when: something rendered wrong; also append new gotchas here after a task*

## The one rule that governs all of it
Every artifact is **one self-contained file that works offline**. Inline the CSS and JS, embed assets as `data:` URIs, and never reference an external host. If it needs a server or the internet to render, it is not done.
