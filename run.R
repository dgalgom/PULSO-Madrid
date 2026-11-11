if (dir.exists('.library')) .libPaths(c(normalizePath('.library'),.libPaths()))
if (!requireNamespace('shiny',quietly=TRUE)) stop('Run Rscript setup.R first.')
shiny::runApp('.',host='127.0.0.1',port=3838,launch.browser=interactive())
