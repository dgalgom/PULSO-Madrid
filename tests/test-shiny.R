# Needs the runtime dependencies; deterministic, no external provider requests.
env <- new.env(parent=globalenv())
app <- source('app.R',local=env,encoding='UTF-8')$value
stopifnot(inherits(app,'shiny.appobj'))
shiny::testServer(env$server, {
  session$setInputs(region='madrid',metric='temperature',hours='48',station='4',threshold=35,
    climate_date=as.Date('2026-07-20'))
  session$flushReact()
  stopifnot(bundle()$mode=='demo',nrow(current_latest())==8)
  stopifnot(grepl('SINT',paste(unlist(output$data_notice),collapse='')))
  stopifnot(grepl('ANOMAL',paste(unlist(output$climate_result),collapse='')))
  stopifnot(nrow(selected_series())==48)
  invisible(output$metrics); invisible(output$chart); invisible(output$station_table)
  session$setInputs(region='galicia',metric='temperature',station='')
  session$flushReact()
  stopifnot(bundle()$mode=='unloaded',nrow(current_latest())==0)
  invisible(output$metrics); invisible(output$station_table)
  session$setInputs(region='catalunya',metric='no2',station='')
  session$flushReact()
  stopifnot(bundle()$mode=='unloaded',nrow(current_latest())==0)
  invisible(output$metrics); invisible(output$station_table)
})
cat('Shiny application construction and regional reactive smoke checks passed.\n')
