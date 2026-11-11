# Network integration checks are reported separately from deterministic CI.
source('R/data.R',encoding='UTF-8'); source('R/regions.R',encoding='UTF-8')
results <- list()
probe <- function(name,fun) {
  tryCatch({
    b <- fun()
    if(is.list(b)&&!is.null(b$observations)) cat(name,':',nrow(b$observations),'real observations;',nrow(b$stations),'stations; latest=',
      format(max(b$observations$time),'%Y-%m-%dT%H:%M:%S%z',tz='Europe/Madrid'),'\n')
    results[[name]] <<- list(ok=TRUE)
  },error=function(e) { cat(name,': FAILED:',conditionMessage(e),'\n'); results[[name]] <<- list(ok=FALSE,error=conditionMessage(e)) })
}
probe('galicia',function() fetch_region('galicia'))
probe('catalunya',function() {
  raw <- json_get(catalunya_url())
  if(length(raw)) { cat('XVPCA fields:',paste(names(raw[[1]]),collapse=','),'\n'); cat('XVPCA units:',scalar(raw[[1]]$unitats),'\n') }
  parse_catalunya(raw)
})
probe('madrid_districts',function() {
  url <- paste0(regional_sources$url[4],'?where=1%3D1&outFields=COD_DIS_TX,NOMBRE&outSR=4326&returnGeometry=true&geometryPrecision=5&maxAllowableOffset=0.0001&f=geojson')
  d <- json_get(url); stopifnot(d$type=='FeatureCollection',length(d$features)==21)
  cat('Madrid: 21 official district polygons verified.\n'); TRUE
})
dir.create('validation-output',showWarnings=FALSE)
jsonlite::write_json(results,'validation-output/providers.json',pretty=TRUE,auto_unbox=TRUE)
if(any(!vapply(results,function(x)x$ok,logical(1)))) stop('One or more external providers failed; inspect provider-specific output.')
