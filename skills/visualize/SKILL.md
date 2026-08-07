---
name: visualize
description: Turn a plan, report, dataset, or explanation into a self-contained visual artifact - a single offline HTML file (default) or a PDF. Use on demand when a wall of markdown is hard to read, when a plan or spec needs reviewing before approval, when data needs a chart or dashboard, or when the deliverable must be a PDF. Triggers on 'visualize', 'visualise', 'render this as HTML', 'make an HTML page', 'make a report page', 'turn this into a page', 'make a visual', 'chart this', 'dashboard for', 'PDF of this', 'export to PDF', 'make this readable'. Do NOT trigger for: editing an existing slide deck or document, generating photos or marketing imagery, or plain prose the user wants to keep as text.
---

# /visualize - build a visual artifact (HTML or PDF)

Produce ONE self-contained file the user can open by double-clicking - no server, no internet, no build step. HTML by default; PDF when the deliverable has to be a PDF. This is an **on-demand** skill: run it when asked, don't auto-convert things the user didn't ask to see visually.

## First action - load context

Read the visualization book's table of contents, then pull only the chapters this request needs:
- **Book:** `books/dataviz/_toc.md` in the knowledge base (the canonical, writable copy). If it isn't there, fall back to `book/dataviz/_toc.md` beside this skill (the copy shipped with the installer).
- Always load `ch02-self-contained-html.md` - the core craft; every artifact is one self-contained file.
- Load `ch03-charts-and-data.md` if the request involves numbers, metrics, or charts.
- Load `ch04-pdf-output.md` if the output must be a PDF.
- Skim `ch01-when-and-format.md` if it's unclear whether to build at all, or which format fits.
- Check `ch05-gotchas.md` before shipping.

Read the book and apply it - don't reproduce it here.

## Flow

1. **Decide what, and whether.** Per ch01: is a visual actually the right call, or is markdown fine? If yes, pick the artifact type - plan/spec, report, data dashboard, or explainer - and the format (HTML unless the user asked for PDF).
2. **Build one self-contained file** per ch02: inline all CSS and JS, embed images/fonts as `data:` URIs, no external requests, responsive, readable in both light and dark, print-friendly. For data, apply ch03 (right chart, accessible color, labels/legend, tables that scroll).
3. **Save it somewhere sensible and open it.** Default: a `visualizations/` folder in the current project (create it), or the path the user names. Use a clear filename (`{topic}-{kind}.html`). Then open it so the user sees it right away.
4. **PDF, if asked:** build the HTML first (steps 2-3), then produce the PDF per ch04. Default is print-to-PDF from the browser (zero dependency); use an automated tool only if one is already installed, and say which.
5. **Iterate:** if the user marks up or asks for changes, keep editing the same file.

## After the task

- Append a one-line entry to `_analytics/usage.log` (per the analytics rule).
- If you hit a rendering gotcha worth remembering (a layout that broke, a print-CSS quirk, a data-URI size limit), append it to `books/dataviz/ch05-gotchas.md`. That write-back is how the book compounds instead of rotting.

## Constraints

- **One file, fully offline.** No CDN links, no external fonts, no fetch/XHR. If it needs the internet to render, it's wrong.
- **On demand only.** Don't turn every plan into HTML by reflex - build when asked.
- **It's a local file, not a hosted link.** The user opens it from disk; where it goes after is their call.
