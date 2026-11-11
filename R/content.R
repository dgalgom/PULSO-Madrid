news <- data.frame(
  date=c('2026-11-11','2026-09-01','2026-07-27','2026-07-01','2026-02-20'),
  publisher=c('EL PAÍS','EL PAÍS','EL PAÍS','EL PAÍS / Cinco Días','Cinco Días'),
  theme=c('EMERGENCIAS · TEMPORAL','SALUD · CALOR','MEDIO AMBIENTE · INCENDIOS',
          'ADAPTACIÓN · CIUDAD','RESILIENCIA · CLIMA'),
  title=c('Lluvia y viento: una jornada de avisos en buena parte del país',
    'Un verano extremo vuelve a poner el calor en el centro de la salud pública',
    'El viento cambia la exposición al humo de los incendios en Madrid',
    'La protección frente al calor también depende del acceso a espacios frescos',
    'Las ciudades preparan su respuesta a los extremos climáticos'),
  summary=c('La cobertura del temporal Bruna y Charles describe riesgo de crecidas y daños por viento. La observación local ayuda a seguir la evolución; no predice inundaciones.',
    'La prensa relaciona el verano de 2026 con un fuerte impacto sanitario. Las estimaciones de mortalidad atribuible no equivalen a defunciones certificadas por golpe de calor.',
    'El episodio de humo muestra por qué conviene consultar partículas y viento conjuntamente. La coincidencia temporal no demuestra el origen de la contaminación.',
    'La cobertura de Sevilla ilustra carencias en la adaptación urbana. El visor de Madrid no incluye un inventario de refugios ni recomienda rutas seguras.',
    'La cobertura de refugios, corredores verdes e infraestructura urbana permite situar los datos ambientales en el contexto de la adaptación.'),
  dataset=c('Meteorología: precipitación (89) y viento (81)',
    'Meteorología: temperatura (83)',
    'Calidad del aire: PM2,5 (9), NO₂ (8), O₃ (14); meteorología: viento (81)',
    'Temperatura y estaciones: apoyo a la observación territorial',
    'Ambas redes: contexto para planificación urbana'),
  url=c('https://elpais.com/el-tiempo/2026-11-11/canarias-se-suma-al-aviso-rojo-que-persiste-en-extremadura-y-castilla-y-leon-por-bruna-y-charles.html',
    'https://elpais.com/clima-y-medio-ambiente/cambio-climatico/2026-09-01/verano-desbocado-en-espana-el-mas-calido-registrado-hasta-ahora-y-el-mas-mortifero-con-mas-de-5000-fallecidos.html',
    'https://elpais.com/espana/madrid/2026-07-27/la-calidad-del-aire-de-madrid-muy-buena-no-es-un-error-es-el-viento-del-este.html',
    'https://elpais.com/espana/2026-07-01/sevilla-afronta-el-calor-extremo-sin-una-red-de-refugios-climaticos.html',
    'https://cincodias.elpais.com/extras/2026-02-20/de-refugios-en-barcelona-a-corredores-naturales-en-bilbao-las-urbes-espanolas-ante-eventos-climaticos-extremos.html'),
  stringsAsFactors=FALSE
)
news$publisher[4] <- 'EL PAÍS'
news <- rbind(news,data.frame(date='2026-11-10',publisher='El Adelantado',
  theme='EMERGENCIAS · ENTORNO URBANO',title='El temporal lleva al cierre preventivo de parques en Segovia',
  summary='La información local describe incidencias en árboles y restricciones preventivas en espacios públicos. Es otro motivo para consultar viento y lluvia junto con las decisiones de las autoridades; los sensores de Madrid no representan Segovia.',
  dataset='Meteorología: viento y precipitación; aplicación limitada a Madrid',
  url='https://eladelantado.com/segovia/2026/11/10/la-borrasca-bruna-acaba-con-la-falta-de-lluvias-que-se-ha-prolongado-durante-mas-de-un-mes/'))

official_links <- list(
  aemet='https://www.aemet.es/es/eltiempo/prediccion/avisos',
  air='https://airedemadrid.madrid.es/',
  health='https://www.comunidad.madrid/salud/calidad-aire-salud'
)
