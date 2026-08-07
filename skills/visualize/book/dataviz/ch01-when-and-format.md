# Ch 1: When to visualize, and which format

## Visualize, or stay in markdown?
A visual is worth the effort when structure or magnitude carries the meaning. Reach for it when:
- A plan or spec is long enough that nobody will actually read it as prose, and it needs reviewing before work starts.
- The content is **relational or quantitative** - steps with dependencies, a comparison, a trend, a breakdown, a before/after.
- Something is easier to *understand by playing with it* - a parameter, a range, a what-if.

Stay in plain markdown when the content is short, linear, or purely textual. A three-line plan does not need a page. Don't visualize by reflex; visualize when it lowers the reader's effort.

## HTML or PDF?
Default to **HTML**. It is the richer format: interactive, responsive, cheap to iterate, and it can still be turned into a PDF later (Ch 4). Choose on what the artifact is for:

| Use HTML when… | Use PDF when… |
|---|---|
| It's for reviewing, exploring, or iterating | It's a final deliverable to send or archive |
| It benefits from interactivity (sliders, toggles, sortable tables) | It must print or paginate predictably |
| It will change again soon | The recipient expects a file, not a link or page |

Rule of thumb: **build HTML first, always.** If a PDF is needed, it is a second step off the same HTML (Ch 4), never a separate effort.

## Match the artifact to the type
- **Plan / spec** → a sectioned page, clear hierarchy, a summary up top, the detail below. Make it skimmable.
- **Report** → headline numbers first (Ch 3), then the supporting detail and tables.
- **Data / dashboard** → charts plus tables; lead with the metric that answers the question.
- **Explainer** → prose plus an interactive demo of the thing being explained (a slider that changes a value, a diagram that responds). The interactivity is the point - a static explainer is just a document.
