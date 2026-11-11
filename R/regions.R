# Regional public-data adapters. No simulated observations are returned on error.
regions <- data.frame(id=c('madrid','galicia','catalunya'),
  label=c('Madrid · municipio','Galicia','Catalunya'),lat=c(40.43,42.85,41.8),lon=c(-3.7,-8.1,1.6),zoom=c(11,8,8))
regional_sources <- data.frame(
  region=c('galicia','galicia','catalunya','madrid'),
  title=c('MeteoGalicia · observaciones horarias','MeteoGalicia · estaciones',
    'Generalitat · calidad del aire XVPCA','Madrid · distritos oficiales'),
  url=c('https://servizos.meteogalicia.gal/mgrss/observacion/ultimosHorariosEstacions.action?numHoras=48&idParam=TA_AVG_1.5m,PP_SUM_1.5m,VV_AVG_10m',
    'https://servizos.meteogalicia.gal/mgrss/observacion/listaEstacionsMeteo.action',
    'https://analisi.transparenciacatalunya.cat/resource/tasf-thgu.json',
    'https://sigma.madrid.es/hosted/rest/services/CARTOGRAFIA/LIMITES_ADMINISTRATIVOS/MapServer/3/query'),
  catalogue=c(rep('https://datos.gob.es/es/catalogo/a12002994-estaciones-meteorologicas1',2),
    'https://datos.gob.es/es/catalogo/a09002970-calidad-del-aire-en-los-puntos-de-medida-automaticos-de-la-red-de-vigilancia-y-prevision-de-la-contaminacio-atmosferica',
    'https://datos.gob.es/es/catalogo/l01280796-distritos-municipales-de-madrid1'),stringsAsFactors=FALSE)

empty_bundle <- function(region) list(observations=empty_observations(),stations=demo_stations()[FALSE,],
  mode='unloaded',region=region,fetched=as.POSIXct(NA),message='Pulsa Conectar datos públicos para consultar esta región.')

json_get <- function(url) {
  h <- curl::new_handle(timeout=35,connecttimeout=10,followlocation=TRUE,useragent='PulsoEspana/2.0')
  r <- curl::curl_fetch_memory(url,handle=h)
  if(r$status_code!=200) stop('HTTP ',r$status_code,' en la fuente pública.')
  if(length(r$content)>25e6) stop('Respuesta superior a 25 MB.')
  jsonlite::fromJSON(rawToChar(r$content),simplifyVector=FALSE)
}
scalar <- function(x,default=NA_character_) if(is.null(x)||!length(x)) default else as.character(x[[1]])

parse_utc <- function(x) {
  # Provider timestamps explicitly named UTC; never infer the machine's local TZ.
  as.POSIXct(sub('Z$','',gsub('T',' ',x,fixed=TRUE)),format='%Y-%m-%d %H:%M:%OS',tz='UTC')
}

parse_galicia <- function(payload,inventory,now=Sys.time()) {
  if(!is.list(payload$listHorarios) || !is.list(inventory$listaEstacionsMeteo)) stop('Esquema MeteoGalicia no compatible.')
  map <- c('TA_AVG_1.5m'='temperature','PP_SUM_1.5m'='rain','VV_AVG_10m'='wind')
  rows <- list()
  for(st in payload$listHorarios) for(t in st$listaInstantes) for(m in t$listaMedidas) {
    code <- scalar(m$codigoParametro)
    # 1: valid original. Interpolated (5), suspect, invalid and unreviewed discarded.
    if(!code %in% names(map) || scalar(m$lnCodigoValidacion)!='1') next
    unit <- scalar(m$unidade)
    allowed <- switch(unname(map[code]),temperature=c('ºC','°C','C'),rain=c('mm','L/m2','l/m2'),wind=c('m/s'))
    if(!unit %in% allowed) next
    rows[[length(rows)+1L]] <- data.frame(station=scalar(st$idEstacion),network='weather',region='galicia',
      metric=unname(map[code]),time=parse_utc(scalar(t$instanteLecturaUTC)),value=numeric_public(scalar(m$valor)))
  }
  if(!length(rows)) stop('MeteoGalicia no contiene horas válidas de los parámetros admitidos.')
  observations <- validate_observations(do.call(rbind,rows),now)
  stations <- do.call(rbind,lapply(inventory$listaEstacionsMeteo,function(st) data.frame(
    station=station_id(scalar(st$idEstacion)),network='weather',name=scalar(st$estacion),
    lat=numeric_public(scalar(st$lat)),lon=numeric_public(scalar(st$lon)))))
  stations <- stations[is.finite(stations$lat)&is.finite(stations$lon)&stations$lat>41&stations$lat<44.5&stations$lon> -10&stations$lon< -6,,drop=FALSE]
  list(observations=observations,stations=stations,region='galicia',mode='live',fetched=now,
    message='MeteoGalicia · datos horarios originales con código 1; se excluyen interpolados. Horas de origen UTC.')
}

catalunya_url <- function(now=Sys.time(),offset=0L) {
  since <- format(as.Date(now,tz='Europe/Madrid')-3,'%Y-%m-%d')
  where <- paste0("data >= '",since,"T00:00:00' AND contaminant in ('NO2','PM2.5','O3')")
  paste0(regional_sources$url[3],'?$where=',URLencode(where,reserved=TRUE),
    '&$order=data%20DESC,codi_eoi,contaminant&$limit=2000&$offset=',offset)
}

parse_catalunya <- function(payload,now=Sys.time()) {
  if(!is.list(payload)||!length(payload)) stop('XVPCA: respuesta vacía.')
  rows <- list(); st <- list()
  map <- c('NO2'='no2','PM2.5'='pm25','O3'='ozone')
  for(a in payload) {
    if(!all(c('codi_eoi','data','contaminant') %in% names(a))) stop('Esquema XVPCA no compatible.')
    metric <- unname(map[scalar(a$contaminant)])
    if(is.na(metric)) next
    unit <- scalar(a$unitats)
    if(!unit %in% c('µg/m³','µg/m3','ug/m3','μg/m3','µg/m^3','μg/m³')) next
    date <- substr(scalar(a$data),1,10)
    # Floating daily date + hourly columns in local civil time. Reject DST days.
    start <- as.POSIXct(date,tz='Europe/Madrid')
    end <- as.POSIXct(as.character(as.Date(date)+1),tz='Europe/Madrid')
    if(is.na(start)||as.numeric(difftime(end,start,units='hours'))!=24) next
    for(h in 1:24) {
      field <- sprintf('h%02d',h); value <- numeric_public(scalar(a[[field]]))
      if(!is.finite(value)||value<0) next
      rows[[length(rows)+1L]] <- data.frame(station=scalar(a$codi_eoi),network='air',region='catalunya',
        metric=metric,time=start+h*3600,value=value)
    }
    st[[length(st)+1L]] <- data.frame(station=station_id(scalar(a$codi_eoi)),network='air',
      name=scalar(a$nom_estacio,scalar(a$municipi)),
      lat=numeric_public(scalar(a$latitud)),lon=numeric_public(scalar(a$longitud)))
  }
  if(!length(rows)) stop('XVPCA: no hay horas numéricas con unidades compatibles.')
  stations <- do.call(rbind,st); stations <- stations[!duplicated(stations$station),]
  stations <- stations[is.finite(stations$lat)&is.finite(stations$lon)&stations$lat>40&stations$lat<43&stations$lon>0&stations$lon<4,,drop=FALSE]
  list(observations=validate_observations(do.call(rbind,rows),now),stations=stations,region='catalunya',mode='live',fetched=now,
    message='Generalitat de Catalunya · XVPCA, concentraciones horarias publicadas. La fuente no incluye un flag V por hora; datos provisionales, no equivalentes a validación final.')
}

fetch_region <- function(region) {
  switch(region,
    madrid={ b <- fetch_live(); b$region <- 'madrid'; b },
    galicia=parse_galicia(json_get(regional_sources$url[1]),json_get(regional_sources$url[2])),
    catalunya={
      all <- list()
      for(page in 0:9) {
        part <- json_get(catalunya_url(offset=page*2000)); all <- c(all,part)
        if(length(part)<2000) break
        if(page==9) stop('XVPCA supera el límite de paginación; no se muestra un resultado truncado.')
      }
      parse_catalunya(all)
    },stop('Región no admitida.'))
}
