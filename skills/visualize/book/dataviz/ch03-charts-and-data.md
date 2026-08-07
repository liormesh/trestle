# Ch 3: Charts and data

Charts are for making a quantitative point fast. Pick the form from the question, color for meaning, and never rely on color alone.

## Pick the chart from the question
- **Compare categories** → bar chart (horizontal if the labels are long).
- **Change over time** → line chart.
- **Part of a whole** → stacked bar; a pie only for 2-3 slices, never more.
- **Relationship between two measures** → scatter.
- **One number that matters** → don't chart it, show it big (a stat tile) with its label and context.

Default to a table when the reader needs exact values rather than a shape.

## Color
- A small, consistent palette. One accent for "the thing," neutral grays for everything else.
- Sequential data (low→high) → one hue, light to dark. Diverging data (below/above a midpoint) → two hues meeting at a neutral middle.
- **Never encode meaning in color alone** - pair it with a label, a shape, or a direct value. Roughly 1 in 12 men can't reliably distinguish red from green.
- Check contrast against the background in both light and dark.

## Labels, legends, tooltips
- Label axes and units. A number without a unit is a riddle.
- Prefer direct labels on the mark over a separate legend when there's room.
- Tooltips are a bonus, not the only home for a value - the artifact must read with the mouse still.

## Tables
- Right-align numbers, left-align text, align decimals.
- Put the column that answers the question first.
- Wrap wide tables in an `overflow-x:auto` container (Ch 2) so they scroll instead of breaking the page.

## Honesty
- Bar charts start at zero. Don't truncate an axis to exaggerate a difference.
- Show the denominator: "32 leads" means little without spend or a rate. A low cost-per-lead with two actual conversions is not a win - surface the metric that actually decides.
