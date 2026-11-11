# Architecture

## Components

| File | Responsibility |
|---|---|
| `app.R` | Shiny layout, reactive state, refresh/import handlers and CSV export |
| `R/data.R` | Indicator definitions, demo generation, CSV adapters, validation and public source registry |
| `R/regions.R` | Region registry, Galicia/Catalunya adapters and source-specific validation |
| `R/climate.R` | Historical import, daily completeness and 20-year daily baseline |
| `R/views.R` | Shared HTML components and SVG map/trend rendering |
| `R/content.R` | Dated newspaper summaries and official reference links |
| `www/style.css` | Responsive visual design and focus/reduced-motion treatment |
| `www/app.js` | Persistent Leaflet map, cached districts, marker updates and Shiny click bridge |
| `preview.R` | Generates a standalone offline preview without Shiny |
| `tests/test-data.R` | Deterministic data semantics, rendering and syntax checks |

## Data flow

```mermaid
flowchart TD
  Demo[Deterministic synthetic scenario] --> Bundle[Session reactive bundle]
  Public[Four municipal distributions] --> Parse[CSV parsing and validation]
  Local[Local observation / station CSV] --> Parse
  Parse --> Bundle
  Bundle --> Latest[Latest readings and freshness]
  Bundle --> Series[Selected station and time window]
  Latest --> Cards[Network maxima and station table]
  Latest --> Map[Persistent Leaflet station map]
  Series --> Trend[SVG hourly trend]
  Bundle --> Export[CSV with mode and provenance]
```

Each session keeps an in-memory bundle per region. Madrid starts in labelled demo mode; Galicia and Catalunya start unloaded. A selected-region refresh replaces only its bundle. Failure preserves the old bundle and displays an error. Madrid supports partial network availability. No missing real readings are filled from the demo.

Station metadata is keyed by both `network` and `station`. A missing official inventory disables plotting for that network instead of borrowing demo coordinates. Tables and time-series inspection can remain available without a map.

## Reactivity and rendering

The selected indicator determines the network, station choices, unit and default exploratory reference. The selected station and hour window filter the trend. Map interaction writes `map_station` through `Shiny.setInputValue`; the server checks the station belongs to the current selection before updating the selector.

Readings age against the current time, reevaluated every minute. Demo mode instead uses the end of its fixed synthetic scenario so the example remains reproducible. The minute timer does not download data. Refresh is manual and synchronous; four requests can temporarily occupy that session while they complete or time out.

The app map uses Leaflet 1.9.4 from a pinned CDN with SRI, CARTO/OpenStreetMap tiles and Canvas sensor markers. The map and tiles are constructed once, markers update in place, and viewport is retained per region. Official Madrid district polygons are queried once per page, cached and hidden in other regions. Failures leave tables usable and show a map status. This reduces avoidable work but is not a measured latency guarantee.

The offline static preview retains a schematic SVG of the Madrid demo. It is not the new interactive interface. The trend chart remains SVG and preserves gaps. Text inserted into SVG/Leaflet HTML is escaped.

The daily-temperature panel uses imported same-station history and a complete target day. Its 20-year daily baseline is never used as an hourly marker cutoff. The demo-only synthetic history is never used for real observations.

## Extension points

- Change `sources` and `parse_observations()` when a provider migrates its schema.
- Add indicator metadata to `metrics`, retaining the correct network, code and units.
- Add geography only after obtaining verified station metadata for that network.
- Update `R/content.R` and `RESEARCH.md` together when revising news evidence.
- Add a cache or background downloader only with explicit freshness and provenance semantics; neither exists today.

The shared view functions power both Shiny and the static preview. The preview's surrounding page is separately assembled; it is not a recording of a running Shiny session.
