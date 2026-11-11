if (dir.exists('.library')) .libPaths(c(normalizePath('.library'),.libPaths()))
required <- c('shiny','htmltools','curl')
missing <- required[!vapply(required,requireNamespace,logical(1),quietly=TRUE)]
if (length(missing)) stop('Instala las dependencias con Rscript setup.R. Faltan: ',paste(missing,collapse=', '))
library(shiny)
source('R/data.R',encoding='UTF-8',local=TRUE)
source('R/content.R',encoding='UTF-8',local=TRUE)
source('R/views.R',encoding='UTF-8',local=TRUE)

ui <- bootstrapPage(
  tags$head(tags$title('PULSO / Madrid · Observatorio ambiental'),
    tags$meta(name='viewport',content='width=device-width, initial-scale=1'),
    tags$link(rel='stylesheet',href='style.css'),tags$script(src='app.js')),
  tags$div(class='app-shell',
    tags$aside(class='sidebar',
      tags$a(class='brand',href='#',tags$span(class='brand-mark','p'),tags$span('PULSO',tags$small('MADRID / OBSERVATORIO'))),
      tags$div(class='sidebar-section','EXPLORAR'),
      radioButtons('page',NULL,choices=c('◎  Monitor ambiental'='monitor','↗  Del titular al dato'='news','▤  Fuentes y método'='sources'),selected='monitor'),
      tags$div(class='sidebar-divider'),
      tags$div(class='sidebar-section','TU VISTA'),
      selectInput('metric','Indicador',choices=setNames(metrics$key,metrics$label),selected='temperature',selectize=FALSE),
      selectInput('station','Estación',choices=NULL,selectize=FALSE),
      selectInput('hours','Ventana temporal',choices=c('Últimas 12 horas'=12,'Últimas 24 horas'=24,'Últimas 48 horas'=48),selected=48,selectize=FALSE),
      uiOutput('threshold_input'),
      tags$p(class='small muted','Referencia exploratoria editable. No es un umbral de alerta oficial ni un índice sanitario.'),
      tags$div(class='sidebar-bottom',tags$span(class='eyebrow','DATOS ABIERTOS. DECISIONES VISIBLES.'),
        tags$p('Una ciudad que entiende su entorno puede prepararse mejor.'),
        tags$a(href=official_links$aemet,target='_blank',rel='noopener noreferrer','Avisos oficiales AEMET ↗'))),
    tags$main(class='main',
      tags$header(class='topbar',tags$span('INTELIGENCIA AMBIENTAL / MADRID'),
        tags$div(class='topbar-actions',uiOutput('mode_badge',inline=TRUE),actionButton('refresh','↻ Conectar datos públicos',class='refresh-button'))),
      uiOutput('data_notice'),
      conditionalPanel("input.page == 'monitor'",
        tags$section(class='hero',tags$div(tags$div(class='eyebrow','EL ENTORNO TAMBIÉN TIENE PULSO'),
          tags$h1('Entiende el presente.',tags$br(),tags$span('Prepárate para lo que viene.')),
          tags$p('Temperatura, lluvia y aire. Una mirada compartida a las señales de tu ciudad.')),
          tags$div(class='hero-orbit','40°25′ N',tags$small('MADRID'),tags$span('↗'))),
        uiOutput('metrics'),
        tags$div(class='main-grid',
          tags$section(class='panel map-panel',panel_heading('01 / TERRITORIO','Cada estación cuenta',uiOutput('map_metric',inline=TRUE)),
            uiOutput('map'),tags$div(class='map-legend',tags$span(class='legend-green','● Bajo referencia'),
              tags$span(class='legend-orange','● En / sobre referencia'),tags$span(class='muted','● Antigua (>3 h)')),
            tags$p(class='map-note','Esquema geográfico WGS84 · puntos de medición, sin interpolación. Selecciona una estación con clic o teclado.')),
          tags$section(class='panel signal-panel',panel_heading('02 / LECTURA','Señales para observar'),uiOutput('signals'),
            tags$div(class='official-callout',tags$span('CONSULTA LA FUENTE OFICIAL'),
              tags$a(href=official_links$aemet,target='_blank',rel='noopener noreferrer','Avisos meteorológicos ↗'),
              tags$a(href=official_links$air,target='_blank',rel='noopener noreferrer','Calidad del aire municipal ↗')))),
        tags$section(class='panel chart-panel',panel_heading('03 / EVOLUCIÓN','El contexto está en la tendencia',uiOutput('chart_title',inline=TRUE)),
          uiOutput('chart'),tags$p(class='map-note','Horas locales de Madrid. Cada punto corresponde al final de su intervalo horario; los huecos se conservan.')),
        tags$section(class='panel table-panel',panel_heading('04 / DETALLE','Última lectura de cada estación',downloadButton('download','↓ Exportar CSV',class='export-button')),
          tags$div(class='table-scroll',tableOutput('station_table')))),
      conditionalPanel("input.page == 'news'",
        tags$section(class='hero',tags$div(tags$span(class='eyebrow','DE LA ACTUALIDAD A UNA HERRAMIENTA'),
          tags$h1('Los titulares plantean',tags$br(),tags$span('las preguntas. Los datos ayudan.')),
          tags$p('Selección editorial revisada el 11 de noviembre de 2026. Los textos de las tarjetas son resúmenes propios; no un servicio de noticias en directo.'))),
        tags$div(class='news-grid',news_cards()),
        tags$section(class='panel prose',tags$h2('La solución elegida'),tags$p('Un observatorio de Madrid para explorar señales ambientales por estación y hora, contrastar episodios con la información pública y exportar las lecturas utilizadas. La prensa orienta las preguntas; los sensores sostienen la visualización.'),
          tags$p('Las noticias de ámbito nacional aportan contexto. Este prototipo cubre el municipio de Madrid: no cubre toda España, no modeliza incendios ni inundaciones y no estima impactos sanitarios.'))),
      conditionalPanel("input.page == 'sources'",
        tags$section(class='hero',tags$div(tags$span(class='eyebrow','TRAZABILIDAD / DATOS.GOB.ES'),
          tags$h1('Detrás de cada señal,',tags$br(),tags$span('una fuente abierta.')))),
        tags$section(class='panel prose',tags$h2('Cuatro conjuntos seleccionados'),
          lapply(seq_len(nrow(sources)),function(i) tags$div(class='source-row',
            tags$div(tags$h3(sources$title[i]),tags$p('Ayuntamiento de Madrid · catálogo nacional datos.gob.es')),
            tags$div(tags$a(href=sources$catalogue[i],target='_blank',rel='noopener noreferrer','Ficha ↗'),
              tags$a(href=sources$url[i],target='_blank',rel='noopener noreferrer','Distribución ↗'))))),
        tags$section(class='panel prose',tags$h2('Cómo leer este observatorio'),
          tags$p('Los indicadores muestran el máximo entre las últimas lecturas de cada estación con una antigüedad de hasta tres horas. No son medias de Madrid. El gráfico y la tabla muestran el indicador seleccionado; las tarjetas superiores permiten comparar los máximos de varias redes.'),
          tags$p('Las referencias iniciales son valores exploratorios: temperatura 35 °C, lluvia 15 mm/h, viento 15 m/s, NO₂ 100 µg/m³, PM2,5 30 µg/m³ y ozono 120 µg/m³. No se calculan el ICA, una predicción ni un nivel oficial de emergencia. No se comparan medias horarias con límites diarios o anuales.'),
          tags$p('Solo se aceptan horas marcadas V, valores numéricos finitos y fechas no futuras. Los datos municipales en tiempo real son provisionales, incluso cuando su flag es V. H24 se sitúa a las 00:00 del día siguiente. Los días de cambio de hora se excluyen porque el formato de 24 columnas no permite desambiguarlos.'),
          tags$p('Las redes de aire y meteorología mantienen identificadores separados. Si no se carga el inventario oficial de una red, sus lecturas no se dibujan con coordenadas de demostración. Una red puede funcionar aunque la otra falle.'),
          tags$p('La conexión es manual: el botón consulta las cuatro distribuciones y nunca mezcla lecturas reales con sintéticas. Un fallo conserva el conjunto anterior y se comunica. El esquema CSV se verifica antes de aceptarlo; una migración del portal puede requerir actualizar el adaptador.'),
          tags$p('Reutilización: atribución al Ayuntamiento de Madrid; conserva la fuente, la fecha de descarga y el carácter provisional. Consulta las condiciones vigentes en cada ficha. Los datos sintéticos del prototipo se distribuyen bajo CC0.'),
          tags$a(href=official_links$health,target='_blank',rel='noopener noreferrer','Información oficial sobre aire y salud ↗')),
        tags$section(class='panel prose',tags$h2('Trabajar con un fichero local'),
          tags$p('Puedes cargar el CSV municipal de formato ancho: ESTACION, MAGNITUD, ANO, MES, DIA y pares H01/V01 … H24/V24. La importación sustituye las lecturas actuales; el modo de demostración deja de estar activo.'),
          selectInput('upload_network','Red del fichero',choices=c('Meteorología'='weather','Calidad del aire'='air'),selectize=FALSE),
          fileInput('upload','Importar observaciones CSV',accept=c('.csv')),
          fileInput('upload_stations','Importar estaciones CSV de la misma red',accept=c('.csv')),
          actionButton('demo','Volver al escenario de demostración',class='refresh-button'))),
      tags$footer('PULSO / MADRID',tags$span('Datos para explorar. Avisos y decisiones de emergencia: consulta a las autoridades.')))))

server <- function(input,output,session) {
  bundle <- reactiveVal(demo_data())
  last_error <- reactiveVal(NULL)
  clock_now <- reactive({ invalidateLater(60000,session); if(bundle()$mode=='demo') max(bundle()$observations$time) else Sys.time() })
  current_metric <- reactive({ req(input$metric); metrics[metrics$key==input$metric,] })
  output$threshold_input <- renderUI({ m <- current_metric(); numericInput('threshold',paste('Referencia /',m$unit),value=m$threshold,min=if(m$key=='temperature') -50 else 0,step=1) })
  threshold <- reactive({ if(is.null(input$threshold)||!is.finite(input$threshold)) current_metric()$threshold else input$threshold })
  current_latest <- reactive(latest_readings(bundle()$observations,current_metric()$key,clock_now()))
  named_latest <- reactive({
    d <- current_latest(); st <- bundle()$stations
    d$name <- st$name[match(paste(d$network,d$station),paste(st$network,st$station))]
    d$name[is.na(d$name)] <- paste('Estación',d$station[is.na(d$name)])
    d
  })
  observe({
    d <- named_latest(); choices <- setNames(d$station,d$name)
    selected <- isolate(input$station)
    if(is.null(selected)||!selected %in% d$station) selected <- if(nrow(d)) d$station[1] else character()
    updateSelectInput(session,'station',choices=choices,selected=selected)
  })
  observeEvent(input$map_station,{
    if(input$map_station %in% named_latest()$station) updateSelectInput(session,'station',selected=input$map_station)
  })
  observeEvent(input$refresh,{
    tryCatch({
      b <- withProgress(message='Consultando las redes municipales',value=0,{
        incProgress(.15,detail='Descarga y validación de las cuatro distribuciones'); result <- fetch_live(); incProgress(.85); result
      })
      bundle(b); last_error(NULL)
    },error=function(e) last_error(paste('No se pudo conectar. Se conserva el conjunto anterior.',conditionMessage(e))))
  })
  observeEvent(input$demo,{ bundle(demo_data()); last_error(NULL) })
  observeEvent(input$upload,{
    req(input$upload)
    tryCatch({
      if(input$upload$size>10e6) stop('El límite es de 10 MB.')
      obs <- parse_observations(read_public_csv(input$upload$datapath),input$upload_network)
      bundle(list(observations=obs,stations=demo_stations()[FALSE,],mode='import',fetched=Sys.time(),
        message='CSV local importado. La fecha de carga no es la fecha de observación.'))
      last_error(NULL)
    },error=function(e) last_error(conditionMessage(e)))
  })
  observeEvent(input$upload_stations,{
    req(input$upload_stations)
    tryCatch({
      if(bundle()$mode=='demo') stop('Importa primero observaciones reales para no mezclar coordenadas oficiales con el escenario sintético.')
      if(input$upload_stations$size>10e6) stop('El límite es de 10 MB.')
      st <- parse_stations(read_public_csv(input$upload_stations$datapath),input$upload_network)
      b <- bundle(); b$stations <- rbind(b$stations[b$stations$network!=input$upload_network,],st); bundle(b); last_error(NULL)
    },error=function(e) last_error(conditionMessage(e)))
  })
  output$mode_badge <- renderUI(tags$span(class=paste('mode-badge',bundle()$mode),
    switch(bundle()$mode,demo='◌ DEMOSTRACIÓN',live='● FUENTE MUNICIPAL',import='▤ CSV LOCAL')))
  output$data_notice <- renderUI({
    b <- bundle()
    tagList(tags$div(class=paste('data-notice',b$mode),role='status',
      tags$strong(if(b$mode=='demo') 'DATOS SINTÉTICOS · ' else 'DATOS PROVISIONALES · '),
      if(b$mode=='demo') 'Escenario de verano ficticio. Las cifras y coordenadas son de demostración, no la situación actual.' else
        paste('Última descarga / carga:',stamp(b$fetched),'. Última observación:',stamp(b$observations$time),'.'),
      if(b$mode!='demo') tags$details(tags$summary('Estado de la conexión'),tags$p(b$message))),
      if(!is.null(last_error())) tags$div(class='error-notice',role='alert',last_error()))
  })
  output$metrics <- renderUI(tags$div(class='metrics-grid',lapply(c('temperature','rain','wind','pm25'),metric_card,bundle=bundle(),now=clock_now())))
  output$map_metric <- renderUI(tags$span(class='dataset-pill',paste(current_metric()$label,'/',current_metric()$unit)))
  output$map <- renderUI(station_map(current_latest(),bundle()$stations,input$station,threshold(),current_metric()$unit))
  output$signals <- renderUI({
    d <- named_latest(); fresh <- d[d$fresh,,drop=FALSE]; count <- sum(fresh$value>=threshold())
    tagList(tags$div(class='signal-number',sprintf('%02d',count),tags$span('estaciones recientes',tags$br(),'en / sobre referencia')),
      tags$p(class='signal-context',paste('De',nrow(fresh),'estaciones recientes para',tolower(current_metric()$label))),
      tags$div(class='signal-item',tags$span(class='signal-dot'),tags$div(tags$strong('Observa la evolución'),tags$p('Compara las horas y las estaciones. Un punto aislado no describe toda la ciudad.'))),
      tags$div(class='signal-item',tags$span(class='signal-dot orange'),tags$div(tags$strong('Contrasta antes de actuar'),tags$p('Consulta los avisos y la información oficial para interpretar un episodio.'))),
      if(any(!d$fresh)) tags$p(class='stale-text',paste(sum(!d$fresh),'estaciones con lecturas antiguas; excluidas del recuento.')))
  })
  selected_series <- reactive({
    req(input$station,input$hours,input$metric)
    d <- bundle()$observations
    d <- d[d$metric==input$metric & d$station==input$station & d$network==current_metric()$network,,drop=FALSE]
    d[d$time>=clock_now()-as.numeric(input$hours)*3600 & d$time<=clock_now(),,drop=FALSE]
  })
  output$chart <- renderUI(trend_chart(selected_series(),threshold(),current_metric()$unit))
  output$chart_title <- renderUI({ d <- named_latest(); name <- d$name[match(input$station,d$station)]; tags$span(class='dataset-pill',paste(name,current_metric()$unit,sep=' / ')) })
  output$station_table <- renderTable({
    d <- named_latest(); d <- d[order(d$value,decreasing=TRUE),,drop=FALSE]
    data.frame(Estación=d$name,Valor=vapply(d$value,fmt,''),Unidad=rep(current_metric()$unit,nrow(d)),
      'Hora local'=format(d$time,'%d/%m/%Y %H:%M',tz='Europe/Madrid'),
      Estado=ifelse(d$fresh,ifelse(d$value>=threshold(),'En / sobre referencia','Bajo referencia'),'Antigua (>3 h)'),check.names=FALSE)
  },striped=FALSE,hover=TRUE,spacing='m',rownames=FALSE)
  output$download <- downloadHandler(filename=function() paste0('pulso-',bundle()$mode,'-',input$metric,'.csv'),
    content=function(file) {
      d <- bundle()$observations
      d <- d[d$metric==input$metric & d$time>=clock_now()-as.numeric(input$hours)*3600 & d$time<=clock_now(),,drop=FALSE]
      d$time <- format(d$time,'%Y-%m-%dT%H:%M:%S%z',tz='Europe/Madrid')
      d$unit <- current_metric()$unit; d$data_mode <- bundle()$mode
      d$source <- if(bundle()$mode=='demo') 'SYNTHETIC_DEMO_CC0' else if(bundle()$mode=='import') 'LOCAL_CSV' else sources$url[match(d$network,sources$id)]
      d$retrieved_at <- if(bundle()$mode=='demo') NA_character_ else format(bundle()$fetched,'%Y-%m-%dT%H:%M:%S%z',tz='Europe/Madrid')
      write.csv(d,file,row.names=FALSE,fileEncoding='UTF-8')
    })
}

shinyApp(ui,server)
