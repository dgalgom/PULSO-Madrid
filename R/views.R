esc <- function(x) as.character(htmltools::htmlEscape(as.character(x),attribute=TRUE))
fmt <- function(x) if (!length(x)||!is.finite(x)) '—' else format(round(x,1),trim=TRUE,nsmall=1)
stamp <- function(x) if (!length(x)||all(is.na(x))) 'Sin datos' else format(max(x,na.rm=TRUE),'%d/%m %H:%M',tz='Europe/Madrid')
panel_heading <- function(kicker,title,aside=NULL) htmltools::tags$div(class='panel-heading',
  htmltools::tags$div(htmltools::tags$span(class='eyebrow',kicker),htmltools::tags$h2(title)),aside)

metric_card <- function(key,bundle,now) {
  info <- metrics[metrics$key==key,]
  d <- latest_readings(bundle$observations,key,now)
  fresh <- d[d$fresh,,drop=FALSE]
  val <- if(nrow(fresh)) max(fresh$value) else NA_real_
  htmltools::tags$article(class=paste('metric-card',key),
    htmltools::tags$div(class='metric-top',htmltools::tags$span(info$label),
      htmltools::tags$span(class='metric-symbol',switch(key,temperature='↗',rain='◌',wind='≋',no2='◈',pm25='⋮',ozone='◎'))),
    htmltools::tags$div(class='metric-number',fmt(val),htmltools::tags$small(info$unit)),
    htmltools::tags$div(class='metric-foot',paste(nrow(fresh),'estaciones recientes'),
      htmltools::tags$span('MÁX. DE LA RED')))
}

station_map <- function(d,stations,selected,threshold,unit) {
  merged <- merge(d,stations,by=c('station','network'))
  if (!nrow(merged)) return(htmltools::tags$div(class='empty',
    htmltools::tags$h3('Sin coordenadas verificadas'),
    htmltools::tags$p('Las lecturas siguen disponibles en el gráfico y la tabla. Carga el inventario de estaciones de esta red para activar el mapa.')))
  # Constant aspect ratio accounts for longitude convergence at Madrid's latitude.
  lonlim <- range(c(-3.82,-3.60,merged$lon),na.rm=TRUE)+c(-.02,.02)
  latlim <- range(c(40.36,40.54,merged$lat),na.rm=TRUE)+c(-.015,.015)
  x <- function(lon) 60+(lon-lonlim[1])/diff(lonlim)*680
  y <- function(lat) 400-(lat-latlim[1])/diff(latlim)*340
  grid <- paste(vapply(seq(lonlim[1],lonlim[2],length.out=6),function(lon)
    sprintf('<path d="M %.1f 35 V 420" stroke="#243445" stroke-dasharray="2 7"/><text x="%.1f" y="442" class="coord">%.2f°</text>',x(lon),x(lon)-14,lon),''),collapse='')
  grid <- paste0(grid,paste(vapply(seq(latlim[1],latlim[2],length.out=5),function(lat)
    sprintf('<path d="M 45 %.1f H 760" stroke="#243445" stroke-dasharray="2 7"/><text x="4" y="%.1f" class="coord">%.2f°</text>',y(lat),y(lat)+4,lat),''),collapse=''))
  points <- vapply(seq_len(nrow(merged)),function(i) {
    a <- merged[i,]; chosen <- identical(a$station,selected)
    color <- if(!a$fresh) '#8192a6' else if(a$value>=threshold) '#ff9d6c' else '#c8f36b'
    label <- paste(a$name,fmt(a$value),unit,stamp(a$time),if(!a$fresh)'· antigua' else '')
    sprintf(paste0('<g class="station-point" role="button" tabindex="0" data-station="%s" aria-label="%s">',
      '<title>%s</title><circle cx="%.1f" cy="%.1f" r="%s" fill="%s" opacity=".12"/>',
      '<circle cx="%.1f" cy="%.1f" r="%s" fill="%s" stroke="%s" stroke-width="2"/>',
      '<text x="%.1f" y="%.1f" class="map-label">%s</text></g>'),
      esc(a$station),esc(label),esc(label),x(a$lon),y(a$lat),if(chosen)'23' else '17',color,
      x(a$lon),y(a$lat),if(chosen)'8' else '6',color,if(chosen)'#fff' else '#132231',
      x(a$lon)+12,y(a$lat)-12,esc(if(chosen) a$name else paste0('E',a$station)))
  },'')
  htmltools::HTML(paste0('<svg class="station-map" viewBox="0 0 800 460" role="group" aria-label="Mapa de estaciones, coordenadas WGS84">',
    '<rect width="800" height="460" fill="#101d29" rx="16"/>',grid,
    '<text x="65" y="65" class="map-watermark">MADRID</text>',paste(points,collapse=''),
    '<path d="M 748 72 L 755 48 L 762 72 L 755 66 Z" fill="#c8f36b"/><text x="751" y="39" class="coord">N</text></svg>'))
}

trend_chart <- function(d,threshold,unit) {
  if (!nrow(d)) return(htmltools::tags$div(class='empty','Esta estación no tiene lecturas en la ventana seleccionada.'))
  d <- d[order(d$time),,drop=FALSE]
  xr <- range(as.numeric(d$time)); if(diff(xr)==0) xr <- xr+c(-1800,1800)
  yr <- range(c(0,d$value,threshold),na.rm=TRUE); yr[2] <- yr[2]+max(1,diff(yr)*.15)
  x <- function(z) 58+(as.numeric(z)-xr[1])/diff(xr)*680
  y <- function(z) 235-(z-yr[1])/diff(yr)*200
  line <- paste(sprintf('%.1f,%.1f',x(d$time),y(d$value)),collapse=' ')
  grid <- paste(vapply(seq(yr[1],yr[2],length.out=5),function(z) sprintf(
    '<path d="M 58 %.1f H 750" stroke="#263543"/><text x="6" y="%.1f" class="coord">%s</text>',y(z),y(z)+4,fmt(z)),''),collapse='')
  ticks <- seq(xr[1],xr[2],length.out=5)
  labels <- paste(vapply(ticks,function(t) sprintf('<text x="%.1f" y="266" class="coord">%s</text>',x(t)-15,
    format(as.POSIXct(t,origin='1970-01-01',tz='Europe/Madrid'),'%d/%m %Hh')),''),collapse='')
  # Separate polylines at missing hours; do not visually fill sensor outages.
  groups <- cumsum(c(TRUE,diff(as.numeric(d$time))>3700))
  lines <- paste(vapply(split(seq_len(nrow(d)),groups),function(idx) sprintf(
    '<polyline points="%s" fill="none" stroke="#c8f36b" stroke-width="3" stroke-linejoin="round"/>',
    paste(sprintf('%.1f,%.1f',x(d$time[idx]),y(d$value[idx])),collapse=' ')),''),collapse='')
  dots <- paste(vapply(seq_len(nrow(d)),function(i) sprintf('<circle cx="%.1f" cy="%.1f" r="4" fill="#c8f36b"><title>%s · %s %s</title></circle>',
    x(d$time[i]),y(d$value[i]),stamp(d$time[i]),fmt(d$value[i]),esc(unit)),''),collapse='')
  htmltools::HTML(paste0('<svg class="trend-chart" viewBox="0 0 800 285" role="img" aria-label="Serie horaria de la estación seleccionada">',grid,
    sprintf('<path d="M 58 %.1f H 750" stroke="#ff9d6c" stroke-dasharray="5 5"/><text x="640" y="%.1f" class="threshold-label">Referencia %s</text>',y(threshold),y(threshold)-8,fmt(threshold)),
    lines,dots,labels,'</svg>'))
}

news_cards <- function() htmltools::tagList(lapply(seq_len(nrow(news)),function(i) {
  n <- news[i,]
  htmltools::tags$article(class='news-card',htmltools::tags$span(class='eyebrow',paste(n$theme,' / ',n$date)),
    htmltools::tags$h3(n$title),htmltools::tags$p(n$summary),
    htmltools::tags$div(class='dataset-pill',n$dataset),
    htmltools::tags$a(href=n$url,target='_blank',rel='noopener noreferrer',paste('Leer en',n$publisher,'↗')))
}))
