# Validation record

Environment: Windows, R 4.6.1, 11 November 2026.

## Regional update

Verified expanded run: [42998136013](https://github.com/dgalgom/PULSO-Madrid/actions/runs/42998136013) passed deterministic tests, Shiny reactive checks, Chromium checks and all three provider probes. The browser fixture measured a 165 ms filter-to-map update on that runner; this is one synthetic local interaction, not an internet latency guarantee.

Live probe snapshot on 11 November 2026: MeteoGalicia returned 14,340 valid hourly readings with 155 station records, latest timestamp `2026-11-11T10:00:00+0100`. The XVPCA probe returned 7,680 hourly readings with 74 station records, latest timestamp `2026-11-10T04:00:00+0100`. That Catalunya feed was delayed and its readings should be marked stale; successful ingestion does not establish freshness. The actual Madrid service returned 21 district polygons. These are dated probe outcomes, not permanently expected counts or bundled measurement files.

- The original CI failure was traced to missing `uv.h` and `curl/curl.h`, cascading into Shiny dependency failures. Ubuntu build prerequisites and package-repository handling were corrected.
- [Repair run 42996276950](https://github.com/dgalgom/PULSO-Madrid/actions/runs/42996276950) passed dependency installation, all 24 original checks, Shiny application construction and preview generation.
- Local Windows checks now also pass `tests/test-regions-climate.R`: 17 checks for daily completeness, exact 20-year coverage, anomaly arithmetic, missing history, regional isolation, provider flag/unit handling, UTC and h24 semantics. Total deterministic assertions: 41.
- Expanded CI includes Shiny reactive smoke tests and Chromium integration for Leaflet, district loading, persistent map/zoom, regional empty states and mobile layout. Consult its run result; configuration alone is not evidence of success.
- Chromium tests use real Leaflet assets from npm and synthetic district fixtures for deterministic testing. Fixture screenshots are named `*-test-fixture.png`. Actual district geometry is checked by an independent network probe, not inferred from those screenshots.
- `tests/provider-probe.R` separately reports real regional observation counts/latest timestamps or failures, plus the 21-feature official district check. This step is nonblocking for external outages and saves `providers.json`. Inspect it even when the workflow is green.
- No real twenty-year station history has been bundled or claimed. The daily comparison is tested with synthetic history; real history must be imported for the same station and a compatible daily-mean definition.

The sections below preserve the original local-sandbox validation record; the regional update above and current workflow evidence supersede its lack of remote Shiny/browser execution.

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
