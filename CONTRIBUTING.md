# Contributing

Start with the [README](README.md), [architecture](docs/ARCHITECTURE.md) and [validation record](VALIDATION.md). This is a standalone Shiny application, not an R package.

## Development

1. Clone the repository and create a branch for your change.
2. Open `pulso-madrid.Rproj` or start R from the repository root.
3. Run `source("setup.R")` to install missing packages into `.library/`.
4. Run `shiny::runApp(".", launch.browser = TRUE)` to inspect the app.
5. Run `Rscript tests/test-data.R` and `Rscript preview.R` before opening a pull request.

Keep source files in UTF-8 with LF line endings. Update the README or relevant guide when changing behavior. Regenerate `preview.html` when changing shared data, view rendering or CSS. Keep the visible UI in Spanish; code comments and project documentation currently use English.

## Meaningful checks

Data-adapter changes should include a small synthetic fixture covering the actual failure being fixed. Do not depend on a successful external feed request for deterministic tests. Check network separation, hour-end timestamps, validity flags, stale data and exported provenance when relevant. Synthetic data must remain clearly labelled.

For UI changes, inspect desktop and mobile layouts, keyboard station selection, long station names, an empty network and missing coordinates. Record what you actually ran; do not describe a generated preview as a successful Shiny browser test.

The GitHub workflow installs dependencies, runs the deterministic checks, constructs the Shiny app object and regenerates the static preview. It does not perform browser interaction tests or verify municipal feed availability.

## Report a problem

Use the bug or data-source issue template. Include the R version, operating system, data mode and reproduction steps. For provider changes, include the public distribution URL and changed column names. Avoid uploading personal data, tokens, local environment dumps or private files.

## Pull requests

Explain the user-visible problem, resulting behavior, validation and remaining limitations. Keep changes focused. Do not introduce official risk classifications, health recommendations, mortality estimates or causal claims without an appropriate verified source and a clearly described method.

Contributions to code and original documentation are accepted under the repository's MIT licence. External data and newspaper material keep their original rights and attribution requirements.
