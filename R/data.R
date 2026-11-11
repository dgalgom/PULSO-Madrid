# Data contract and transformations. This file deliberately needs only base R.
metrics <- data.frame(
  key = c('temperature', 'rain', 'wind', 'no2', 'pm25', 'ozone'),
  label = c('Temperatura', 'Precipitación', 'Viento', 'Dióxido de nitrógeno', 'Partículas PM2,5', 'Ozono'),
  unit = c('°C', 'mm/h', 'm/s', 'µg/m³', 'µg/m³', 'µg/m³'),
  code = c(83, 89, 81, 8, 9, 14),
  network = c(rep('weather', 3), rep('air', 3)),
  threshold = c(35, 15, 15, 100, 30, 120), stringsAsFactors = FALSE
)

empty_observations <- function() data.frame(station=character(), network=character(),
  metric=character(), time=as.POSIXct(character(), tz='Europe/Madrid'), value=numeric())

demo_stations <- function() {
  # Approximate demonstration coordinates; never used to geolocate live readings.
  d <- data.frame(station=c('4','8','16','18','24','35','36','58'),
    name=c('Plaza de España','Escuelas Aguirre','Arturo Soria','Farolillo','Casa de Campo',
           'Plaza del Carmen','Moratalaz','El Pardo'),
    lat=c(40.4239,40.4216,40.4400,40.3948,40.4194,40.4192,40.4079,40.5181),
    lon=c(-3.7123,-3.6823,-3.6392,-3.7319,-3.7473,-3.7032,-3.6453,-3.7746))
  rbind(transform(d,network='weather'),transform(d,network='air'))
}

demo_data <- function() {
  stations <- demo_stations()
  # Fixed, reproducible scenario: these are NOT observations from this date.
  times <- seq(as.POSIXct('2026-07-19 17:00:00',tz='Europe/Madrid'),by='hour',length.out=48)
  rows <- list(); n <- 0L
  for (i in seq_len(nrow(stations))) for (j in which(metrics$network==stations$network[i])) {
    h <- as.integer(format(times,'%H',tz='Europe/Madrid'))
    offset <- (i-1) %% 8
    values <- switch(metrics$key[j],
      temperature=29+8*sin((h-8)/24*2*pi)+offset*.45,
      rain=pmax(0, 17*sin((h-13)/24*2*pi)-15+offset*.15),
      wind=3+2*sin(h/24*2*pi)+offset*.3,
      no2=30+18*cos((h-8)/24*2*pi)+offset*4,
      pm25=12+6*sin((h-10)/24*2*pi)+offset*2.1,
      ozone=66+45*sin((h-8)/24*2*pi)+offset*3)
    n <- n+1L
    rows[[n]] <- data.frame(station=stations$station[i],network=stations$network[i],
      metric=metrics$key[j],time=times,value=round(values,1))
  }
  list(observations=do.call(rbind,rows),stations=stations,mode='demo',
       fetched=as.POSIXct(NA),message='Escenario sintético reproducible. No representa la situación actual.')
}

canonical_names <- function(x) {
  x <- iconv(x,from='',to='ASCII//TRANSLIT',sub='')
  toupper(gsub('[^a-zA-Z0-9]','',x))
}

read_public_csv <- function(path) {
  first <- readLines(path,n=1,warn=FALSE,encoding='UTF-8')
  if (!length(first) || grepl('<!doctype|<html',first,ignore.case=TRUE)) stop('La fuente no contiene un CSV.')
  sep <- if (length(strsplit(first,';',fixed=TRUE)[[1]]) > length(strsplit(first,',',fixed=TRUE)[[1]])) ';' else ','
  d <- tryCatch(read.table(path,header=TRUE,sep=sep,quote='"',comment.char='',
    check.names=FALSE,stringsAsFactors=FALSE,fileEncoding='UTF-8-BOM',colClasses='character'),
    error=function(e) stop('No se puede leer el CSV: ',conditionMessage(e)))
  names(d) <- canonical_names(names(d)); d
}

numeric_public <- function(x) suppressWarnings(as.numeric(gsub(',','.',as.character(x),fixed=TRUE)))

station_id <- function(x) {
  x <- as.character(x)
  # Municipality-prefixed station IDs: 28079004 -> 4.
  x <- sub('^28079','',x)
  as.character(suppressWarnings(as.integer(x)))
}

validate_observations <- function(d, now=Sys.time()) {
  required <- c('station','network','metric','time','value')
  if (!all(required %in% names(d))) stop('Esquema de observaciones incompleto.')
  if (!inherits(d$time,'POSIXct')) stop('La fecha debe incluir hora y zona horaria.')
  d$station <- station_id(d$station)
  d <- d[!is.na(d$station) & is.finite(d$value) & !is.na(d$time) & d$time<=now+300 &
           d$metric %in% metrics$key & d$network %in% c('air','weather'),required,drop=FALSE]
  # Do not silently mix pollutant codes from a different network.
  d <- d[d$network==metrics$network[match(d$metric,metrics$key)],,drop=FALSE]
  d <- d[d$value>=0 | d$metric=='temperature',,drop=FALSE]
  if (!nrow(d)) stop('No hay observaciones válidas para los indicadores admitidos.')
  key <- paste(d$station,d$network,d$metric,as.numeric(d$time),sep=':')
  d <- d[!duplicated(key,fromLast=TRUE),,drop=FALSE]
  d[order(d$time,d$station),,drop=FALSE]
}

parse_observations <- function(d,network,now=Sys.time()) {
  names(d) <- canonical_names(names(d))
  core <- c('ESTACION','MAGNITUD','ANO','MES','DIA')
  if (!all(core %in% names(d))) stop('Formato no compatible: se requieren ESTACION, MAGNITUD, ANO, MES y DIA.')
  result <- list()
  for (hour in 1:24) {
    h <- sprintf('H%02d',hour); v <- sprintf('V%02d',hour)
    if (!all(c(h,v) %in% names(d))) next
    m <- metrics$key[match(as.integer(d$MAGNITUD),metrics$code)]
    date <- sprintf('%04d-%02d-%02d',as.integer(d$ANO),as.integer(d$MES),as.integer(d$DIA))
    # Madrid H01 is the mean for 00:00–01:00; H24 ends at next-day midnight.
    time <- as.POSIXct(date,tz='Europe/Madrid') + hour*3600
    # Legacy daily-wide files cannot disambiguate DST transition hours safely.
    next_midnight <- as.POSIXct(as.character(as.Date(date)+1),tz='Europe/Madrid')
    day_start <- as.POSIXct(date,tz='Europe/Madrid')
    regular_day <- as.numeric(difftime(next_midnight,day_start,units='hours'))==24
    good <- toupper(trimws(d[[v]]))=='V' & !is.na(m) & regular_day
    good[is.na(good)] <- FALSE
    if (any(good)) result[[length(result)+1L]] <- data.frame(station=d$ESTACION[good],
      network=network,metric=m[good],time=time[good],value=numeric_public(d[[h]][good]))
  }
  if (!length(result)) stop('No hay horas válidas (V). Los días de cambio horario se excluyen.')
  validate_observations(do.call(rbind,result),now)
}

parse_stations <- function(d,network) {
  names(d) <- canonical_names(names(d))
  pick <- function(options) { x <- intersect(options,names(d)); if(!length(x)) stop('Faltan campos de estaciones: ',paste(options,collapse='/')); d[[x[1]]] }
  result <- data.frame(station=station_id(pick(c('CODIGO','CODIGOESTACION','ESTACION'))),
    network=network,name=pick(c('ESTACION','NOMBRE','DENOMINACION')),
    lat=numeric_public(pick(c('LATITUD','LATITUDE'))),lon=numeric_public(pick(c('LONGITUD','LONGITUDE'))))
  # Require decimal WGS84 coordinates; never guess UTM/DMS.
  result <- result[!is.na(result$station) & is.finite(result$lat) & is.finite(result$lon) &
      result$lat>40 & result$lat<41 & result$lon> -4.2 & result$lon< -3,,drop=FALSE]
  if (!nrow(result)) stop('No hay coordenadas WGS84 decimales utilizables.')
  result[!duplicated(result$station),,drop=FALSE]
}

latest_readings <- function(d,metric,now=Sys.time(),max_age_hours=3) {
  d <- d[d$metric==metric & d$time<=now+300,,drop=FALSE]
  d <- d[order(d$time,decreasing=TRUE),,drop=FALSE]
  d <- d[!duplicated(paste(d$network,d$station)),,drop=FALSE]
  d$age_hours <- as.numeric(difftime(now,d$time,units='hours'))
  d$fresh <- d$age_hours<=max_age_hours
  d
}

sources <- data.frame(
  id=c('air','weather','air_stations','weather_stations'),
  title=c('Calidad del aire · tiempo real','Meteorología · tiempo real',
          'Estaciones de calidad del aire','Estaciones meteorológicas'),
  catalogue=paste0('https://datos.gob.es/es/catalogo/l01280796-',c(
    'calidad-del-aire-datos-en-tiempo-real1','datos-meteorologicos-datos-en-tiempo-real1',
    'calidad-del-aire-estaciones-de-control1','datos-meteorologicos-estaciones-de-control1')),
  url=c('https://ciudadesabiertas.madrid.es/dynamicAPI/API/query/calair_tiemporeal.csv?pageSize=5000',
    'https://datos.madrid.es/egob/catalogo/300392-11041819-meteorologia-tiempo-real.csv',
    'https://datos.madrid.es/dataset/212629-0-estaciones-control-aire/resource/212629-0-estaciones-control-aire-csv/download/212629-0-estaciones-control-aire-csv.csv',
    'https://datos.madrid.es/egob/catalogo/300360-1-meteorologicos-estaciones.csv'),
  stringsAsFactors=FALSE
)

fetch_csv <- function(url) {
  dest <- tempfile(fileext='.csv'); on.exit(unlink(dest))
  handle <- curl::new_handle(timeout=18,connecttimeout=8,followlocation=TRUE,useragent='PulsoMadrid/1.0')
  curl::curl_download(url,dest,handle=handle,quiet=TRUE)
  if(file.info(dest)$size>10e6) stop('El fichero supera el límite de 10 MB.')
  read_public_csv(dest)
}

fetch_live <- function() {
  observations <- list(); stations <- list(); status <- character()
  for (network in c('air','weather')) {
    u <- sources$url[sources$id==network]
    observations[[network]] <- tryCatch(parse_observations(fetch_csv(u),network),error=function(e) {
      status <<- c(status,paste(network,conditionMessage(e),sep=': ')); NULL
    })
    stations[[network]] <- tryCatch(parse_stations(fetch_csv(sources$url[sources$id==paste0(network,'_stations')]),network),error=function(e) {
      status <<- c(status,paste('Estaciones',network,conditionMessage(e))); NULL
    })
  }
  obs <- do.call(rbind,observations)
  if (is.null(obs) || !nrow(obs)) stop(paste('No se ha podido cargar ninguna red.',paste(status,collapse=' | ')))
  st <- do.call(rbind,stations)
  if (is.null(st)) st <- demo_stations()[FALSE,]
  # No synthetic data or approximate coordinates are ever substituted here.
  list(observations=obs,stations=st,mode='live',fetched=Sys.time(),
    message=if(length(status)) paste(status,collapse=' | ') else 'Lecturas municipales provisionales; pendientes de revisión.')
}
