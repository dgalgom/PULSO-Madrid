source('R/data.R',encoding='UTF-8'); source('R/regions.R',encoding='UTF-8'); source('R/climate.R',encoding='UTF-8')
checks <- 0L
check <- function(x,label) { stopifnot(isTRUE(x)); checks <<- checks+1L; cat('PASS:',label,'\n') }
fails <- function(expr) inherits(tryCatch(force(expr),error=identity),'error')
b <- demo_data(); now <- max(b$observations$time)
c <- climate_comparison(b$observations,demo_history(),'madrid','4',as.Date('2026-07-20'))
check(c$complete && c$n_years==20 && c$hours==24,'20-year same-day comparison requires complete daily observations')
check(c$period=='2006–2025' && abs(c$baseline-26.29)<1e-8,'Baseline is equal-weight mean of prior 20 daily means')
check(abs(c$anomaly-(c$observed-c$baseline))<1e-8,'Daily anomaly compares like-for-like daily means')
h <- demo_history(); h <- h[h$date!=as.Date('2006-07-20'),]
c <- climate_comparison(b$observations,h,'madrid','4',as.Date('2026-07-20'))
check(!c$complete && is.na(c$baseline) && c$n_years==19,'Missing historical year never silently interpolated')
c <- climate_comparison(b$observations,demo_history(),'madrid','4',as.Date('2026-07-21'))
check(is.na(c$observed) && !c$complete,'Partial day cannot be compared with daily history')
check(fails(parse_history(rbind(demo_history(),demo_history()[1,]))),'Duplicate daily means rejected')
check(nrow(parse_history(demo_history()))==160,'History schema validated')
c <- climate_comparison(b$observations,demo_history(),'galicia','4',as.Date('2026-07-20'))
check(c$n_years==0 && is.na(c$baseline),'Historical baselines are isolated by region')
check(identical(station_id(c('A001','28079004','004')),c('A001','4','4')),'Alphanumeric regional IDs preserved')
obs <- validate_observations(b$observations,now)
both <- rbind(obs,transform(obs,region='galicia'))
check(nrow(validate_observations(both,now))==2*nrow(obs),'Same sensor codes in different regions never collide')
payload <- list(listHorarios=list(list(idEstacion=10157,estacion='Coruña',listaInstantes=list(
  list(instanteLecturaUTC='2026-07-20T12:00:00',listaMedidas=list(
    list(codigoParametro='TA_AVG_1.5m',lnCodigoValidacion=1,unidade='ºC',valor=24.2),
    list(codigoParametro='PP_SUM_1.5m',lnCodigoValidacion=2,unidade='mm',valor=99),
    list(codigoParametro='VV_AVG_10m',lnCodigoValidacion=1,unidade='m/s',valor=3)))))))
inv <- list(listaEstacionsMeteo=list(list(idEstacion=10157,estacion='Coruña',lat=43.382763,lon=-8.409202)))
g <- parse_galicia(payload,inv,now)
check(nrow(g$observations)==2 && all(g$observations$region=='galicia'),'Galicia filters invalid flags and maps official metric codes')
check(format(g$observations$time[1],'%H',tz='Europe/Madrid')=='14','Galicia UTC is explicitly converted for display')
check(nrow(g$stations)==1 && g$stations$lon== -8.409202,'Galicia preserves official decimal coordinates')
catrow <- list(codi_eoi='08019057',data='2026-07-20T00:00:00.000',contaminant='NO2',unitats='µg/m3',
  nom_estacio='Barcelona',latitud='41.4',longitud='2.1',h01='22.1',h02='-999',h24='18')
ct <- parse_catalunya(list(catrow),now)
check(nrow(ct$observations)==2 && all(ct$observations$metric=='no2'),'Catalunya rejects missing/sentinel pollution values')
check(format(max(ct$observations$time),'%Y-%m-%d %H:%M',tz='Europe/Madrid')=='2026-07-21 00:00','Catalunya h24 hour-end semantics')
check(nrow(ct$stations)==1 && ct$region=='catalunya','Catalunya metadata included without demo fallback')
check(grepl('%24',URLencode('$')) || grepl('offset=2000',catalunya_url(offset=2000),fixed=TRUE),'Catalunya pagination has explicit offset')
cat(checks,'regional/climate checks passed.\n')
