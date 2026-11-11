# Explicit daily comparison, distinct from the exploratory hourly cut-off.
parse_history <- function(d) {
  names(d) <- tolower(names(d))
  required <- c('region','station','date','tmean','source')
  if(!all(required %in% names(d))) stop('Histórico: requiere region, station, date, tmean y source.')
  d <- d[,required]; d$date <- as.Date(d$date); d$tmean <- numeric_public(d$tmean)
  d$station <- station_id(d$station)
  if(any(is.na(d$date)|!is.finite(d$tmean)|is.na(d$station)|!nzchar(d$source))) stop('Histórico: fechas, valores o fuentes incompletos.')
  if(any(duplicated(paste(d$region,d$station,d$date)))) stop('Histórico: más de una media para la misma estación y día.')
  d
}

daily_temperature <- function(observations,station,date) {
  start <- as.POSIXct(as.character(as.Date(date)),tz='Europe/Madrid')
  end <- as.POSIXct(as.character(as.Date(date)+1),tz='Europe/Madrid')
  expected <- seq(start+3600,end,by='hour')
  d <- observations[observations$station==station & observations$metric=='temperature' &
    observations$time>start & observations$time<=end,,drop=FALSE]
  # Require every distinct hourly interval and forbid duplicate network records.
  complete <- nrow(d)==length(expected) && identical(sort(as.numeric(d$time)),sort(as.numeric(expected))) && all(is.finite(d$value))
  list(mean=if(complete) mean(d$value) else NA_real_,hours=length(unique(d$time)),expected=length(expected),complete=complete)
}

climate_comparison <- function(observations,history,region,station,date,years=20L) {
  date <- as.Date(date); end_year <- as.integer(format(date,'%Y'))-1L
  baseline_years <- seq(end_year-years+1L,end_year)
  targets <- paste0(baseline_years,format(date,'-%m-%d'))
  # No Feb-29 interpolation; report insufficient coverage rather than invent data.
  d <- history[history$region==region & history$station==station & as.character(history$date) %in% targets,,drop=FALSE]
  daily <- daily_temperature(observations,station,date)
  complete <- nrow(d)==years && length(unique(format(d$date,'%Y')))==years
  baseline <- if(complete) mean(d$tmean) else NA_real_
  list(baseline=baseline,observed=daily$mean,anomaly=if(complete && daily$complete) daily$mean-baseline else NA_real_,
    n_years=nrow(d),years=years,period=paste(range(baseline_years),collapse='–'),hours=daily$hours,
    expected_hours=daily$expected,complete=complete && daily$complete,sources=unique(d$source))
}

empty_history <- function() data.frame(region=character(),station=character(),date=as.Date(character()),tmean=numeric(),source=character())

demo_history <- function() {
  # Explicitly synthetic; never made available for real/imported observations.
  d <- expand.grid(station=demo_stations()$station[1:8],year=2006:2025,stringsAsFactors=FALSE)
  data.frame(region='madrid',station=d$station,date=as.Date(paste0(d$year,'-07-20')),
    tmean=26+(d$year-2006)*.02+match(d$station,d$station[1:8])*.1,source='SYNTHETIC_DEMO_CC0')
}
