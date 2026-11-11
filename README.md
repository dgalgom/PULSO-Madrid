# PULSO / Madrid

[![R checks](https://github.com/dgalgom/PULSO-Madrid/actions/workflows/r-checks.yml/badge.svg)](https://github.com/dgalgom/PULSO-Madrid/actions/workflows/r-checks.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-c8f36b.svg)](LICENSE)

An R Shiny environmental observatory, built from a review of datos.gob.es and Spanish newspaper coverage on 11 November 2026. The interface is in Spanish. Its purpose is to explore local environmental observations during heat, pollution and severe-weather episodes.

**Status: research prototype.** The bundled preview uses synthetic data. The original development environment passed 24 data/rendering checks but could not run Shiny or verify live ingestion. See [validation](VALIDATION.md) before interpreting the dashboard.

## Get the project

```sh
git clone https://github.com/dgalgom/PULSO-Madrid.git
cd PULSO-Madrid
```

Use a current R release with UTF-8 support; development checks used R 4.6.1. RStudio is optional. Internet access is needed for dependency installation and official-data refresh, but the static preview works offline.

## Open the result

Download or clone the repository and open [preview.html](preview.html) in your browser for a self-contained static design preview. GitHub's file viewer displays its source rather than running the page. It uses the same synthetic data, map and trend renderers as the app. It has no external assets or runtime dependencies. The preview is not the interactive Shiny application.

Open **pulso-madrid.Rproj** in RStudio, then run:

```r
source("setup.R")
shiny::runApp(".", launch.browser = TRUE)
```

Or from a terminal in this directory:

```text
Rscript setup.R
Rscript run.R
```

The terminal launch binds only to http://127.0.0.1:3838. Required packages: `shiny`, `htmltools`, `curl`. No API key, JavaScript package manager or mapping service is required. `setup.R` needs internet access to CRAN for missing packages and installs them in the project-local `.library` directory. Open a new R session from this project or run `run.R` so that directory is available on the library path.

## What it does

- Six selectable indicators: temperature, hourly precipitation, wind, NO2, PM2.5 and ozone.
- An interactive geographical station plot, with mouse and keyboard selection, plus a station selector.
- Hourly trends, selectable 12/24/48-hour windows and an editable exploratory reference.
- Latest readings and explicit stale-data status. KPI cards show network maxima of recent station readings, not city averages.
- Manual refresh from four official public distributions; separate failures for each network and its metadata.
- CSV import for offline work and export with mode, units, time-zone offsets and source information.
- News-to-dataset explanation and links to every catalogue record, distribution and newspaper article.
- Responsive dark navy interface, lime highlights, warm signal accents, custom SVG graphics and no dependency on web fonts or online map tiles.

## Data modes and limitations

The app **starts in DEMONSTRATION mode**. All sensor values in that mode are generated, and station coordinates are approximate demo positions. The fixed 48-hour scenario ends on 21 July 2026 at 16:00 Madrid time; it does not describe actual conditions on that date or today. Both the app and its exports identify synthetic data.

Use **Conectar datos públicos** to attempt official downloads. Municipal readings are provisional. If a network fails, another network can still load; missing station coordinates remain missing. If every observation download fails, the previous bundle remains and an error is shown. The app never substitutes synthetic observations or demo coordinates for missing official data. Downloads are manual; the age of readings is reevaluated every minute. Nothing is silently described as live just because it was recently downloaded.

The sources were verified at the **catalogue and distribution-link level**. This environment blocked external shell downloads, so the current CSV payloads and live adapters could not be tested against the live providers. The parser supports the municipal wide hourly schema; incompatible migrated schemas are explicitly rejected. The app's supported local import is the same format. Adapt `parse_observations()` if the provider changes column structure. API pagination is requested at 5,000 rows; the selected wide hourly feed should be well below that, but this was not verified against a live response.

Shiny was absent from the installed R library and could not be downloaded in this environment. **The Shiny session and browser interactions have not been run here.** The data transformations, SVG renderers and R syntax were checked with the installed R runtime; see `VALIDATION.md`.

This is a municipal exploration prototype, not an emergency service. Its references are editable analytical values, not official warning thresholds, an air-quality index or medical recommendations. It does not forecast floods, estimate deaths, identify pollution causes or find safe routes/refuges. The map shows sensor points, not continuous exposure. News from elsewhere in Spain is context, not evidence that Madrid has the same conditions.

## Offline import

In **Fuentes y método**, choose the network and import an observation CSV with:

```text
ESTACION;MAGNITUD;ANO;MES;DIA;H01;V01;...;H24;V24
28079004;83;2026;07;20;28,4;V;...;30;V
```

`MAGNITUD`: weather 83 temperature (°C), 89 precipitation (mm per hour), 81 wind (m/s); air 8 NO2, 9 PM2.5, 14 O3 (µg/m³). Only hours flagged `V` are retained; all other flags are discarded. A `V` flag does not mean the provisional municipal feed has been finally reviewed. `H01` ends at 01:00 and `H24` ends at the following midnight, Europe/Madrid. DST transition days are excluded because this fixed-width daily format cannot safely express their 23/25 hours. Future timestamps, nonfinite values, negative pollution/rain/wind and duplicate station-hour records are excluded.

Importing observations starts a separate local bundle without official coordinates. Optionally import a station CSV for that network with `CODIGO`, `ESTACION` (name), `LATITUD`, `LONGITUD`, in decimal WGS84. This enables the map. Numeric station IDs and municipality-prefixed IDs are normalized, keeping air/weather networks separate. Unsupported UTM/DMS coordinates are rejected.

## Verify and regenerate

```text
Rscript tests/test-data.R
Rscript preview.R
```

The project-local `.Rprofile` enables UTF-8 character handling on Windows when necessary. No user-global R settings are changed. See [RESEARCH.md](RESEARCH.md) for selection rationale and [VALIDATION.md](VALIDATION.md) for the actual validation limits. GitHub Actions is configured to install dependencies, run the data checks, construct the Shiny app object and regenerate the preview. A workflow configuration is not evidence of a passing remote run; check the Actions tab for its actual result.

## Documentation

| Guide | Contents |
|---|---|
| [Research](RESEARCH.md) | Newspaper evidence, dataset review and selection rationale |
| [Architecture](docs/ARCHITECTURE.md) | Components, data flow and extension points |
| [Data dictionary](docs/DATA_DICTIONARY.md) | Fields, units, freshness, validation and provenance |
| [Operations](docs/OPERATIONS.md) | First run, troubleshooting and deployment considerations |
| [Validation](VALIDATION.md) | Completed checks, unverified behavior and manual checklist |
| [Contributing](CONTRIBUTING.md) | Development workflow and reporting problems |
| [Changelog](CHANGELOG.md) | Changes included in the initial prototype |

## Files

`app.R` is the Shiny UI/server. `R/data.R` contains the data contract, adapters, validation and synthetic scenario. `R/views.R` renders shared SVG and HTML views. `R/content.R` holds attributed editorial summaries. `www/` contains original CSS and the small keyboard/click bridge. `preview.R` generates the offline preview. `tests/test-data.R` checks data semantics and rendering without Shiny.

## Licence and attribution

The application code and original documentation are licensed under [MIT](LICENSE), copyright 2026 dgalgom. The supplied synthetic data is CC0. Official data remains subject to the terms linked in its catalogue records; attribute Ayuntamiento de Madrid and preserve provisional status, retrieval times and provenance. Newspaper links and original short summaries are provided instead of copied articles. The MIT licence does not relicense third-party datasets, articles or dependencies.
