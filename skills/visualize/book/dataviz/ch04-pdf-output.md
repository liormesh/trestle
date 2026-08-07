# Ch 4: PDF output

A PDF is a second step off a finished HTML artifact (Ch 2), never a separate build. Get the HTML right, then print it well.

## Default path: print-to-PDF (no dependencies)
1. Build and open the HTML.
2. Print (Cmd/Ctrl+P) → destination **Save as PDF**.
3. This uses the browser's own engine, needs nothing installed, and honors the print CSS below.

Recommend this path by default - it is zero-dependency and matches the framework's no-install promise.

## Make the print good with `@page` and print CSS
- `@page { margin: 18mm; }` for sane margins (or `size: A4` / `letter` when it matters).
- In `@media print`: hide interactive chrome (buttons, sliders), force a light background and dark text.
- Control breaks: `page-break-inside: avoid` on cards, table rows, and charts so they don't split across pages; `page-break-before` before major sections.
- Re-check: nothing clipped at the page edge, no chart cut in half, no orphaned headers.

## Automated path (only if a tool is already available)
If PDFs must be generated without a human clicking Print, and a tool is already installed, use it - don't install one just for this:
- **Headless Chromium** (`chrome --headless --print-to-pdf`) - best fidelity, same engine as the manual path.
- **wkhtmltopdf** or **WeasyPrint** - lighter, but CSS support lags; verify the output, don't assume it.

Name which tool you used. If none is available, fall back to the manual path and say so - never silently pull in a dependency.

## When PDF is the wrong answer
If the artifact is interactive (sliders, sortable tables), a PDF throws that away. Deliver the HTML and offer the PDF as a static snapshot, not a replacement.
