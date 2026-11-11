# Running and troubleshooting

## Local use

Clone the project, open its RStudio project and run `source("setup.R")`. This installs missing runtime packages into `.library/`. Start with `source("run.R")`, or `shiny::runApp(".", launch.browser = TRUE)` from the same session. Terminal users can run `Rscript setup.R` followed by `Rscript run.R` and open `http://127.0.0.1:3838`.

The app starts in a labelled synthetic scenario. **Conectar datos públicos** attempts four public downloads. The data status panel identifies the mode and observation timestamps. **Fuentes y método** exposes source links and local CSV imports.

## Troubleshooting

| Symptom | Check |
|---|---|
| Missing Shiny package | Run `setup.R` with working CRAN access; restart from the project root so `.library/` is included |
| Cannot install packages | Confirm the project directory is writable and HTTPS access to CRAN is allowed; do not commit the package library |
| Accented characters fail on Windows | Start from the project so `.Rprofile` enables UTF-8; ensure your source CSV is UTF-8 |
| Live connection fails | Open the linked distribution, check network/provider status, and inspect the displayed schema error |
| Live table works but map is empty | Check the station inventory for that specific network; no demo coordinates are substituted |
| Some metrics have no readings | Different networks and sensors measure different indicators; unavailable measurements stay missing |
| Recent download but stale observations | Download time is not observation time; inspect the actual latest timestamps |
| Historic imported file shows an empty trend | The app's 12/24/48-hour window is relative to now; use recent observations or extend the app for historical dates |
| GitHub shows HTML source | Clone/download the repository and open `preview.html` locally; it is not hosted automatically |

## Hosting

No deployment is configured. `run.R` intentionally binds to localhost. A Shiny-capable host can run the project after installing its dependencies and allowing outbound HTTPS to the selected public feeds. GitHub Pages alone cannot run an R Shiny server; it could host only the generated static preview.

Before shared use, run the manual checklist in [VALIDATION.md](../VALIDATION.md), verify current feed schemas and inspect a successful workflow run. The current refresh is synchronous, without a shared persistent cache or background worker. Decide on hosting capacity and any provider access limits before exposing it to many users. Neither authentication nor a production deployment configuration is supplied.

## Maintenance

Review catalogue distribution links and adapter compatibility when a source changes. Update news references deliberately; there is no live news scraper. Keep `VALIDATION.md` honest about what has been run, including the date and environment. Record meaningful changes in `CHANGELOG.md`.
