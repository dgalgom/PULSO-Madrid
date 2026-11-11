if(!dir.exists('.library')) dir.create('.library')
.libPaths(c(normalizePath('.library'),.libPaths()))
required <- c('shiny','htmltools','curl')
missing <- required[!vapply(required,requireNamespace,logical(1),quietly=TRUE)]
if(length(missing)) install.packages(missing,lib='.library',repos='https://cloud.r-project.org')
if(!all(vapply(required,requireNamespace,logical(1),quietly=TRUE))) stop('Installation incomplete.')
message('Ready. Run: shiny::runApp(".", launch.browser = TRUE)')
