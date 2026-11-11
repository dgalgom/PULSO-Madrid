# PULSO / España

[![R checks](https://github.com/dgalgom/PULSO-Madrid/actions/workflows/r-checks.yml/badge.svg)](https://github.com/dgalgom/PULSO-Madrid/actions/workflows/r-checks.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-c8f36b.svg)](LICENSE)

An R Shiny environmental observatory with official-data adapters for Madrid, Galicia and Catalunya, built from datos.gob.es and Spanish newspaper research. The interface is in Spanish. The expanded application is named **PULSO España**; the existing GitHub repository URL remains `dgalgom/PULSO-Madrid` for continuity. It does not claim complete national coverage.

**Status: research prototype.** The bundled preview uses synthetic data. There are 41 deterministic data/rendering checks plus Shiny and browser integration checks in CI. Official-provider probes run separately and are allowed to fail on external outages; a green workflow alone does not establish feed availability. See [validation](VALIDATION.md) and the latest Actions logs for actual results.

## Get the project

```sh
git clone https://github.com/dgalgom/PULSO-Madrid.git
cd PULSO-Madrid
```

Use a current R release with UTF-8 support; development checks used R 4.6.1. RStudio is optional. Internet access is needed for dependency installation and official-data refresh, but the static preview works offline.

## Open the result

Download or clone the repository and open [preview.html](preview.html) in your browser for a self-contained static design preview. GitHub's file viewer displays its source rather than running the page. It uses the same synthetic data, map and trend renderers as the app. It has no external assets or runtime dependencies. The preview is not the interactive Shiny application.

Open **pulso-espana.Rproj** in RStudio, then run:

```r
source("setup.R")
shiny::runApp(".", launch.browser = TRUE)
```

Or from a terminal in this directory:

```text
Rscript setup.R
Rscript run.R
```

The terminal launch binds only to http://127.0.0.1:3838. Required R packages: `shiny`, `htmltools`, `curl`, `jsonlite`. Leaflet 1.9.4 is loaded from a CDN with integrity hashes; map tiles use CARTO/OpenStreetMap. No API key is required. Runtime does not need npm; CI uses npm for browser validation. `setup.R` installs missing R packages into `.library/`, preserving a configured package repository. On Ubuntu, install `libuv1-dev`, `libcurl4-openssl-dev`, `libssl-dev` and `pkg-config` first. Open a new R session from this project or run `run.R` so that directory is available.

## What it does

- Six selectable indicators: temperature, hourly precipitation, wind, NO2, PM2.5 and ozone.
- A persistent Leaflet map with zoom/pan, Canvas station markers, popups and 21 official Madrid district polygons. The station selector provides keyboard access.
- Hourly trends, selectable 12/24/48-hour windows and an editable exploratory reference.
- Latest readings and explicit stale-data status. KPI cards show network maxima of recent station readings, not city averages.
- Regional refresh: Madrid weather/air, Galicia weather, Catalunya air. Each region keeps its own session cache. Missing indicators and coordinates remain missing.
- A daily-temperature comparison with an explicit same-calendar-day baseline over the prior 20 years, distinct from the hourly exploratory limit.
- CSV import for offline work and export with mode, units, time-zone offsets and source information.
- News-to-dataset explanation and links to every catalogue record, distribution and newspaper article.
- Responsive dark navy interface, lime highlights, warm signal accents, Leaflet geography and SVG time-series charts. Map tiles and CDN assets require network access; the standalone static preview remains offline.

## Coverage and sources

| Territory | Indicators | Official source |
|---|---|---|
| Madrid municipality | Weather and air | Ayuntamiento de Madrid hourly CSVs and station inventories |
| Galicia | Temperature, precipitation, wind | MeteoGalicia hourly observations and station inventory |
| Catalunya | NO2, PM2.5, ozone | Generalitat XVPCA / Socrata dataset `tasf-thgu` |

See the catalogue links and exact request URLs in [regional research](RESEARCH.md) and `R/regions.R`. Galicia accepts only validation code 1 (original valid data); Catalunya's published hourly columns do not supply the Madrid `V` flag and remain explicitly provisional. It is not valid to infer identical data quality across providers.

## What is the temperature reference?

The old **35 °C** reference was only an editable exploratory threshold. It is now labelled **Límite exploratorio horario**. It is not a historical average or a health warning threshold.

The separate **20-year daily baseline** for date D in year Y is:

```text
baseline = mean(daily_mean(same station, same month/day, years Y-20 through Y-1))
daily_anomaly = complete daily mean on D - baseline
```

For 20 July 2026, use the twenty daily means for 20 July in 2006–2025. All 20 distinct years are required, with equal weight; missing years and February 29 are not interpolated. The selected day's hourly observations must cover every hourly interval before its mean is compared. An incomplete day is not compared with complete historical days. The hourly chart never uses a daily baseline as a threshold.

Import UTF-8 history with `region,station,date,tmean,source` under **Fuentes y método**. History must use the same station and consistent daily-mean definition; it cannot mix a nearby AEMET station with a municipal sensor. No real 20-year history is bundled or automatically inferred from the short live feeds. Madrid's municipal weather archive starts in 2019 and cannot itself support a 20-year baseline. Demo mode includes an explicitly synthetic 20-year example. This custom rolling baseline is distinct from AEMET's standard 1991–2020 climate normals. See [CLIMATOLOGY.md](docs/CLIMATOLOGY.md).

## Data modes and limitations

The app **starts in DEMONSTRATION mode**. All sensor values in that mode are generated, and station coordinates are approximate demo positions. The fixed 48-hour scenario ends on 21 July 2026 at 16:00 Madrid time; it does not describe actual conditions on that date or today. Both the app and its exports identify synthetic data.

Select a region and use **Conectar datos públicos** to attempt official downloads. Regions outside Madrid start unloaded, with no fabricated observations. If a request fails, its previous bundle remains and an error is shown. Madrid's weather/air networks can load independently. Downloads are manual; changing filters does not redownload data. The age of readings is reevaluated every minute. Nothing is silently described as fresh merely because it was recently downloaded.

Provider availability and schema compatibility are checked by `tests/provider-probe.R` on GitHub, separately from deterministic CI. Its logs record real observation counts and timestamps or source-specific failures. The original local sandbox cannot download these feeds. The Madrid adapter still requires compatible municipal wide-hourly CSVs. Catalunya's adapter paginates recent records and rejects a truncated result. Source changes produce visible errors rather than a synthetic fallback.

The original CI installation failure was traced to missing native `libuv` and `libcurl` headers; the corrected job passed installation, data checks and Shiny construction. Expanded CI also exercises Shiny reactivity and a Chromium session. Browser tests use real Leaflet code with synthetic district fixtures; the independent provider probe checks the actual official district response. No performance guarantee is claimed without measurement.

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
Rscript tests/test-regions-climate.R
Rscript tests/test-shiny.R
Rscript preview.R
```

The project-local `.Rprofile` enables UTF-8 character handling on Windows when necessary. No user-global R settings are changed. See [RESEARCH.md](RESEARCH.md) for selection rationale and [VALIDATION.md](VALIDATION.md) for actual validation results. Browser screenshots and provider outcomes are attached to workflow runs as `validation-evidence` when produced; fixture screenshots are named as such.

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
