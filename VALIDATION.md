# Validation record

Environment: Windows, R 4.6.1, 11 November 2026.

## Passed

- `Rscript tests/test-data.R`: 24 checks passed with the installed R runtime.
- Deterministic demonstration data: 2,304 readings, six metrics, eight demo stations in each relevant network, 48 hours.
- Validity flag filtering, decimal commas, station-code normalization, negative-temperature handling and rejection of negative pollution.
- Madrid local-hour semantics, H24 midnight rollover, exclusion of future readings and ambiguous DST transition days.
- Network separation, deduplication, most-recent reading selection and three-hour freshness classification.
- Decimal WGS84 station parsing and rejection of projected coordinates.
- Station map output, accessible station targets, explicit missing-coordinate state and chart gaps during outages.
- End-to-end semicolon CSV parsing and rejection of HTML masquerading as data.
- Syntax parsing of the application and all R entry points.
- `Rscript preview.R`: standalone `preview.html` generated from the same data and SVG renderers.

## Not verified in this environment

- Shiny startup, reactive behavior, downloads, uploads and browser interaction: `shiny` is not installed. The setup script is supplied, but this session cannot install it from CRAN because external local-process network access is blocked. No successful Shiny session is claimed.
- The live CSV response bodies and adapters: public catalogue pages and distribution links were inspected through the web tool, but neither the web reader nor the local shell supplied usable CSV bodies. Live adapters have explicit schema checks and visible failure states. No real measurements are bundled.
- Desktop/mobile browser rendering: a headless Edge attempt failed with Windows sandbox access-denied errors before a screenshot was produced. There is no screenshot artifact or claimed visual browser pass. The static preview can be opened manually.

## First run with normal network access

1. Copy this project out of temporary storage to a permanent directory.
2. Open the RStudio project and run `source("setup.R")`, then `source("run.R")`.
3. Confirm the demo banner, change all six indicators, change station by selector and map, and check keyboard selection.
4. Try the 12/24/48-hour windows and editable reference; verify the table, graph and CSV export.
5. Click **Conectar datos públicos**; check each source's status, actual observation timestamps and fresh/stale labeling. If the provider has changed its schema, update the adapter using the linked specification before claiming live operation.
6. Import a compatible local observation CSV, then its network station inventory; confirm no demo coordinates remain.
7. Resize the browser to mobile width and inspect layout and focus states.
