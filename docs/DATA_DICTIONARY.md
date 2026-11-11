# Data dictionary and provenance

## Normalized observations

| Field | Type | Meaning |
|---|---|---|
| `station` | character | Normalized station code; `28079004` becomes `4` |
| `network` | character | `weather` or `air`; part of station identity |
| `metric` | character | One of the six indicator keys below |
| `time` | POSIXct | Hour-end timestamp in `Europe/Madrid` |
| `value` | numeric | Finite reading in the indicator's native unit |

Station metadata uses `station`, `network`, `name`, `lat` and `lon`. Coordinates must be decimal WGS84 within the implemented Madrid bounds. The parser does not convert UTM or degrees/minutes/seconds.

| Indicator key | Municipal magnitude | Network | Unit | Initial exploratory reference |
|---|---:|---|---|---:|
| `temperature` | 83 | weather | °C | 35 |
| `rain` | 89 | weather | mm in the hourly interval, displayed as mm/h | 15 |
| `wind` | 81 | weather | m/s | 15 |
| `no2` | 8 | air | µg/m³ | 100 |
| `pm25` | 9 | air | µg/m³ | 30 |
| `ozone` | 14 | air | µg/m³ | 120 |

These references are editable exploration aids. They are not official warning thresholds or an air-quality index. No daily/annual legal limit is compared with an hourly reading.

## Supported municipal CSV

The wide format requires `ESTACION`, `MAGNITUD`, `ANO`, `MES`, `DIA` and hourly value/flag pairs `H01`/`V01` through `H24`/`V24`. Recognized valid hours must have flag `V`. The parser supports comma decimal values and detects comma versus semicolon separators. Source files currently need UTF-8 encoding; convert legacy encodings to UTF-8 before local import if necessary.

`H01` ends at 01:00; `H24` ends at midnight of the following local day. Days with a daylight-saving transition are excluded because the daily-wide format cannot safely disambiguate the extra/missing hour. Observations more than five minutes into the future are discarded. Duplicate network/station/metric/timestamp records keep the last supplied record. Negative weather values are accepted only for temperature.

Validation flags are a technical filter, not proof that a provisional feed has completed official quality review. Unknown schemas and unusable files produce explicit errors.

## Freshness and aggregation

For the selected metric, the latest reading is chosen separately for every station. Readings up to three hours old are marked recent. Older readings remain visible in the table/map but are excluded from the signal count and KPI maxima. KPI cards show the maximum among recent latest station readings for their metric, not a spatial average or a historical maximum.

## Export

The export contains all stations for the selected metric and time window, not only the selected chart station. It adds `unit`, `data_mode`, `source` and `retrieved_at`. Time strings include the UTC offset. `data_mode` is `demo`, `live` or `import`.

Demo exports use source `SYNTHETIC_DEMO_CC0`. Imported-file exports use `LOCAL_CSV`; the original local filename is not preserved. Municipal exports use the corresponding distribution URL. `retrieved_at` is the bundle download/import time, not the observation time or a separate per-request timestamp. No real observation snapshot is bundled in this repository.

## External rights

Application code and original documentation: [MIT](../LICENSE). Generated synthetic scenario: CC0. Municipal data: the terms linked in each [catalogue record](../RESEARCH.md), with Ayuntamiento de Madrid attribution and provisional status preserved. Newspaper articles are linked, not redistributed; summaries are original short paraphrases. Dependencies retain their own licences.
