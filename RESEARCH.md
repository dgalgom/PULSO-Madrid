# Research and selection — 11 November 2026

## Catalogue review

The requested [datasets landing page](https://datos.gob.es/es/catalogo/conjuntos-datos) was fetched, but exposed no readable catalogue content to the web tool. Individual catalogue records were accessible, so the review continued through those records and their distribution links. This is a targeted review of relevant datasets, not an exhaustive audit of the national catalogue.

| Reviewed data | Relevance | Selection |
|---|---|---|
| [Madrid air quality, real time](https://datos.gob.es/es/catalogo/l01280796-calidad-del-aire-datos-en-tiempo-real1) | Particles, NO2 and ozone can contextualize pollution and smoke exposure | Selected observations; catalogue describes provisional automatic measurements |
| [Madrid weather, real time](https://datos.gob.es/es/catalogo/l01280796-datos-meteorologicos-datos-en-tiempo-real1) | Temperature, precipitation and wind contextualize heat and storms | Selected observations |
| [Air-quality station inventory](https://datos.gob.es/es/catalogo/l01280796-calidad-del-aire-estaciones-de-control1) | Spatial location and station names | Selected metadata; never infer weather station identity from air station codes |
| [Weather station inventory](https://datos.gob.es/es/catalogo/l01280796-datos-meteorologicos-estaciones-de-control1) | Coordinates for the weather network | Selected metadata |
| [Madrid hourly weather archive since 2019](https://datos.gob.es/es/catalogo/l01280796-datos-meteorologicos-datos-horarios-desde-20191) | Retrospective episode analysis | Reviewed; local CSV import supports compatible files, but the app does not crawl the archive |

The inventories make maps possible; they are not additional measurements. Catalogue dates can describe metadata rather than observation freshness. The app therefore checks the timestamps of the readings themselves.

Additional official resources reviewed: [AEMET predictions](https://www.aemet.es/es/eltiempo/prediccion/) and [OpenData catalogue](https://opendata.aemet.es/centrodedescargas/productosAEMET); [MITECO climate-refuge network](https://www.miteco.gob.es/es/pacto-emergencia-climatica/red-refugios-climaticos.html); [Community of Madrid: air quality and health](https://www.comunidad.madrid/salud/calidad-aire-salud). A national warning aggregator, refuge finder or flood model would need additional verified spatial data, access arrangements and semantics. Those were not included in this bounded prototype.

## Newspaper themes → useful datasets → implementation

| News source and date | Problem identified in coverage | Data match and application |
|---|---|---|
| [El País, 11 November 2026](https://elpais.com/el-tiempo/2026-11-11/canarias-se-suma-al-aviso-rojo-que-persiste-en-extremadura-y-castilla-y-leon-por-bruna-y-charles.html) | Storm conditions and official weather warnings | Weather rainfall/wind readings and hourly evolution, with a direct official AEMET warnings link; no flood forecast |
| [El Adelantado, 10 November 2026](https://eladelantado.com/segovia/2026/11/10/la-borrasca-bruna-acaba-con-la-falta-de-lluvias-que-se-ha-prolongado-durante-mas-de-un-mes/) | Urban tree damage and preventive park closure in Segovia | Motivates monitoring wind and rain; Madrid implementation does not claim Segovia coverage or live closure status |
| [El País, 1 September 2026](https://elpais.com/clima-y-medio-ambiente/cambio-climatico/2026-09-01/verano-desbocado-en-espana-el-mas-calido-registrado-hasta-ahora-y-el-mas-mortifero-con-mas-de-5000-fallecidos.html) | Heat as a public-health concern | Temperature network, station comparison and trends; no mortality estimates or clinical risk predictions |
| [El País, 27 July 2026](https://elpais.com/espana/madrid/2026-07-27/la-calidad-del-aire-de-madrid-muy-buena-no-es-un-error-es-el-viento-del-este.html) | Wind changes how Madrid is exposed to wildfire smoke | PM2.5 and wind observations in one tool; no assertion that a particular particle reading came from a fire |
| [El País, 1 July 2026](https://elpais.com/espana/2026-07-01/sevilla-afronta-el-calor-extremo-sin-una-red-de-refugios-climaticos.html) | Uneven access to cooling infrastructure | Supports the adaptation problem; excluded refuge routing because no verified Madrid refuge inventory was obtained |
| [Cinco Días, 20 February 2026](https://cincodias.elpais.com/extras/2026-02-20/de-refugios-en-barcelona-a-corredores-naturales-en-bilbao-las-urbes-espanolas-ante-eventos-climaticos-extremos.html) | Cities preparing for extreme weather through urban adaptation | Context for local environmental observation; no infrastructure effectiveness claim |

These are dated editorial references, not a live news feed. Article summaries in the app are original paraphrases. Dates refer to the articles, not to the synthetic demonstration data. Access was through web results and readable article content; the newspaper front pages were not exhaustively scraped. RTVE's 11 November storm coverage was also reviewed as corroborating public-broadcaster context.

## Why this solution

The recurring need is to put environmental measurements in one place with enough time and spatial context to interpret an episode. The selected municipal feeds offer a coherent first geography and matching observation formats. A local dashboard can help a journalist, analyst or municipal team inspect an event and export the supporting readings. It cannot establish causality or turn a sensor reading into an official emergency warning.

## Distribution access and uncertainty

The catalogue air feed now points to `ciudadesabiertas.madrid.es/dynamicAPI/API/query/calair_tiemporeal.csv?pageSize=5000`; the weather record points to `datos.madrid.es/egob/catalogo/300392-11041819-meteorologia-tiempo-real.csv`. The exact four links are recorded in `R/data.R` and exposed in the application. Their current payloads could not be downloaded in this sandbox. The live code is therefore an explicitly unverified adapter with schema checks and visible failure states, not a claimed successful ingestion of today's measurements.

The browser tool could read metadata and articles, but did not provide usable CSV bodies. The local shell's configured network route also rejected downloads. No real observations are bundled or fabricated. A deterministic synthetic scenario makes the prototype reviewable offline.
