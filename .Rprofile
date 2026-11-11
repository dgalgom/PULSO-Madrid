# Some managed Windows sessions start R in the C locale despite UTF-8 files.
if (.Platform$OS.type == 'windows' && !isTRUE(l10n_info()[['UTF-8']])) {
  invisible(suppressWarnings(try(Sys.setlocale('LC_CTYPE', '.UTF-8'), silent = TRUE)))
}
if (dir.exists('.library')) .libPaths(c(normalizePath('.library'), .libPaths()))
