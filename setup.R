if(!dir.exists('.library')) dir.create('.library')
.libPaths(c(normalizePath('.library'),.libPaths()))
required <- c('shiny','htmltools','curl','jsonlite')
missing <- required[!vapply(required,requireNamespace,logical(1),quietly=TRUE)]
repos <- getOption('repos')
if(is.null(repos) || !length(repos) || any(repos=='@CRAN@')) repos <- c(CRAN='https://cloud.r-project.org')
if(length(missing)) install.packages(missing,lib='.library',repos=repos,Ncpus=2L)
unavailable <- required[!vapply(required,requireNamespace,logical(1),quietly=TRUE)]
if(length(unavailable)) stop('Installation incomplete. Missing: ',paste(unavailable,collapse=', '),
  '. On Ubuntu install libuv1-dev, libcurl4-openssl-dev and libssl-dev; inspect the first package build error above.')
message('Ready. Run: shiny::runApp(".", launch.browser = TRUE)')
