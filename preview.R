# Static design preview, generated from the same data and SVG renderers as the app.
# It needs htmltools, not Shiny. It deliberately has no pretend interactive controls.
source('R/data.R',encoding='UTF-8')
source('R/content.R',encoding='UTF-8')
source('R/views.R',encoding='UTF-8')
library(htmltools)
b <- demo_data(); now <- max(b$observations$time)
d <- latest_readings(b$observations,'temperature',now)
series <- b$observations[b$observations$station=='4' & b$observations$metric=='temperature',]
st <- b$stations[b$stations$network=='weather',]
table_data <- merge(d,st,by=c('station','network'))
row <- function(i) tags$tr(tags$td(table_data$name[i]),tags$td(fmt(table_data$value[i])),tags$td('°C'),tags$td(stamp(table_data$time[i])))
page <- tags$html(lang='es',tags$head(tags$meta(charset='UTF-8'),
  tags$meta(name='viewport',content='width=device-width, initial-scale=1'),
  tags$title('PULSO / Madrid · Vista previa estática'),
  tags$style(HTML(paste(readLines('www/style.css',encoding='UTF-8'),collapse='\n')))),
  tags$body(tags$div(class='app-shell',
    tags$aside(class='sidebar',tags$div(class='brand',tags$span(class='brand-mark','p'),tags$span('PULSO',tags$small('MADRID / OBSERVATORIO'))),
      tags$div(class='sidebar-section','VISTA PREVIA ESTÁTICA'),
      tags$a(href='#monitor','◎  Monitor ambiental'),tags$br(),tags$a(href='#news','↗  Del titular al dato'),tags$br(),tags$a(href='#sources','▤  Fuentes públicas'),
      tags$div(class='sidebar-divider'),tags$p(class='muted','Temperatura · Plaza de España · 48 horas'),
      tags$p(class='small muted','Esta vista previa muestra el diseño con datos sintéticos. Ejecuta la aplicación Shiny para cambiar filtros, seleccionar estaciones, importar y exportar datos.'),
      tags$div(class='sidebar-bottom',tags$span(class='eyebrow','DATOS ABIERTOS. DECISIONES VISIBLES.'),tags$p('Una ciudad que entiende su entorno puede prepararse mejor.'))),
    tags$main(class='main',id='monitor',
      tags$header(class='topbar',tags$span('INTELIGENCIA AMBIENTAL / MADRID'),tags$span(class='mode-badge demo','◌ DEMOSTRACIÓN · VISTA ESTÁTICA')),
      tags$div(class='data-notice demo',tags$strong('DATOS SINTÉTICOS · '),'Escenario de verano ficticio. Las cifras y coordenadas son de demostración, no la situación actual.'),
      tags$section(class='hero',tags$div(tags$div(class='eyebrow','EL ENTORNO TAMBIÉN TIENE PULSO'),
        tags$h1('Entiende el presente.',tags$br(),tags$span('Prepárate para lo que viene.')),
        tags$p('Temperatura, lluvia y aire. Una mirada compartida a las señales de tu ciudad.')),
        tags$div(class='hero-orbit','40°25′ N',tags$small('MADRID'),tags$span('↗'))),
      tags$div(class='metrics-grid',lapply(c('temperature','rain','wind','pm25'),metric_card,bundle=b,now=now)),
      tags$div(class='main-grid',tags$section(class='panel map-panel',panel_heading('01 / TERRITORIO','Cada estación cuenta',tags$span(class='dataset-pill','Temperatura / °C')),
        station_map(d,b$stations,'4',35,'°C'),tags$div(class='map-legend',tags$span(class='legend-green','● Bajo referencia'),tags$span(class='legend-orange','● En / sobre referencia')),
        tags$p(class='map-note','Esquema geográfico WGS84 · coordenadas aproximadas de demostración.')),
        tags$section(class='panel signal-panel',panel_heading('02 / LECTURA','Señales para observar'),
          tags$div(tags$div(class='signal-number',sprintf('%02d',sum(d$value>=35)),tags$span('estaciones recientes',tags$br(),'en / sobre referencia')),
            tags$p(class='signal-context','De 8 estaciones de demostración para temperatura'),
            tags$div(class='signal-item',tags$span(class='signal-dot'),tags$div(tags$strong('Observa la evolución'),tags$p('Compara las horas y las estaciones. Un punto aislado no describe toda la ciudad.'))),
            tags$div(class='signal-item',tags$span(class='signal-dot orange'),tags$div(tags$strong('Contrasta antes de actuar'),tags$p('Referencia exploratoria: 35 °C. No es un nivel oficial de alerta.')))),
          tags$div(class='official-callout',tags$span('CONSULTA LA FUENTE OFICIAL'),tags$a(href=official_links$aemet,'Avisos meteorológicos ↗'),tags$a(href=official_links$air,'Calidad del aire municipal ↗')))),
      tags$section(class='panel',panel_heading('03 / EVOLUCIÓN','El contexto está en la tendencia',tags$span(class='dataset-pill','Plaza de España / °C')),
        trend_chart(series,35,'°C'),tags$p(class='map-note','Horas locales de Madrid · escenario sintético · 19–21 de julio de 2026.')),
      tags$section(class='panel',panel_heading('04 / DETALLE','Última lectura de cada estación'),
        tags$div(class='table-scroll',tags$table(class='table',tags$thead(tags$tr(lapply(c('Estación','Valor','Unidad','Hora local'),tags$th))),tags$tbody(lapply(seq_len(nrow(table_data)),row))))),
      tags$section(class='hero',id='news',tags$div(tags$span(class='eyebrow','DE LA ACTUALIDAD A UNA HERRAMIENTA'),tags$h1('Los titulares plantean',tags$br(),tags$span('las preguntas. Los datos ayudan.')),
        tags$p('Selección editorial revisada el 11 de noviembre de 2026. Resúmenes propios.'))),
      tags$div(class='news-grid',news_cards()),
      tags$section(class='panel prose',id='sources',tags$h2('Fuentes públicas seleccionadas'),
        lapply(seq_len(nrow(sources)),function(i) tags$div(class='source-row',tags$div(tags$h3(sources$title[i]),tags$p('Ayuntamiento de Madrid · datos.gob.es')),tags$a(href=sources$catalogue[i],'Ficha del catálogo ↗'))),
        tags$p('Este prototipo explora observaciones locales. No estima impactos sanitarios, no predice inundaciones ni sustituye avisos oficiales.')),
      tags$footer('PULSO / MADRID',tags$span('Vista previa estática · ejecuta Shiny para usar los controles.'))))))
save_html(page,'preview.html',background='#0b141e')
cat('Generated preview.html\n')
