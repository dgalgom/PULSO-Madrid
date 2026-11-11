# Changelog

## Unreleased

### Regional map and comparison update

- Renamed the application and RStudio project to PULSO España; existing repository URL retained.
- Fixed CI's missing native libuv/libcurl headers and preserved the runner's configured package repository; the repair run passed.
- Replaced the app's schematic map with persistent Leaflet, Canvas station updates and official Madrid district polygons.
- Distinguished the editable hourly limit from a complete-day anomaly against the same station/calendar day in the previous 20 years.
- Added official-data adapters and regional state for Galicia weather and Catalunya air quality.
- Added 17 regional/climate checks, Shiny reactive smoke checks, Chromium integration checks and separately reported provider probes.

### Initial research prototype

- Spanish-language Shiny environmental dashboard for Madrid.
- Temperature, precipitation, wind, NO2, PM2.5 and ozone selection.
- Station map with keyboard selection, hourly trends, adjustable exploratory reference and CSV export.
- Explicit synthetic-demo, municipal-source and local-import modes.
- Four official distribution adapters with schema checks and separate network metadata.
- News-to-dataset research, offline HTML preview and 24 deterministic checks.
- MIT licence, contributor guidance, architecture and data documentation, issue templates and an R validation workflow.

Live feed payloads and a full interactive Shiny session were not validated in the original sandbox. No release or successful remote CI run is implied by this entry.
