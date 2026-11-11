# Temperature comparisons

## Two different questions

**Hourly exploratory limit:** Is this hourly station reading at or above a user-selected value? The initial value is 35 °C. It is an analytical cutoff, not a climate normal, official alert or health-risk calculation. It colours hourly map points and the hourly trend reference line.

**Daily historical anomaly:** How does the complete selected day's mean compare with the same calendar day at the same station in the previous 20 years? This is computed in a separate panel and never substituted into the hourly marker classification.

For target year Y, month M and day D:

`B = (1/20) × sum(Tmean(y,M,D)), y = Y-20,...,Y-1`

`anomaly = Tmean(Y,M,D) - B`

Example: 20 July 2026 uses the twenty daily means for 20 July 2006–2025, each with equal weight. For a different target year, the preceding twenty-year period changes explicitly. It is a rolling empirical comparison, not a fixed WMO normal.

## Completeness and comparability

- Require all 20 distinct historical years. Do not silently change the period or average fewer years.
- The target day's observed mean needs every distinct hourly interval, using end-of-hour timestamps and the region's local civil day. In the current supported regions that is Europe/Madrid.
- Wide daily provider formats exclude DST transition days when they cannot distinguish repeated/missing hours. Such a date remains unavailable rather than approximated.
- Do not interpolate February 29. Without twenty matching valid daily means, comparison is unavailable.
- History must use the same physical station, region, units and a daily-mean definition compatible with the arithmetic mean of the hourly intervals. A daily `(maximum + minimum)/2` statistic is not interchangeable with this hourly-derived mean.
- The imported CSV does not prove metadata continuity, calibration or homogenization. The uploader must establish station and method comparability. This is exploratory analysis, not an official homogenized climatological product.

## History import

UTF-8 CSV columns: `region,station,date,tmean,source`. Regions are `madrid`, `galicia`, `catalunya`; dates are ISO `YYYY-MM-DD`; temperature is °C. Each row is one complete daily mean. Duplicate station/region/date keys are rejected, as are missing dates, values or source attribution. Historical data is held only in the current session.

No real 20-year station series is bundled. The municipal Madrid weather archive begins in 2019, so it cannot independently satisfy this comparison. The short live MeteoGalicia feed also cannot supply twenty years. Use a verified long station series and preserve its provenance. The demo history is generated, labelled synthetic and never used for real observations.

## Official climate normals are different

[AEMET's climate statistics](https://www.aemet.es/es/datos_abiertos/estadisticas/vigilancia_clima) use the standard 1991–2020 reference period from January 2023. Those official normals are distinct from the custom preceding-20-year same-day comparison. A monthly climate normal must not be labelled a same-day normal, and a normal from another station must not be presented as this sensor's history.
