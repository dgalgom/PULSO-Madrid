/* Leaflet 1.9.4: preserve map, tiles and per-region viewport; update station layers. */
(() => {
  let map, stationLayer, districts, currentRegion, districtPromise;
  const markers = new Map(), views = new Map();
  const status = text => { const el = document.getElementById('geo-status'); if (el) el.textContent = text; };
  const safe = text => { const el = document.createElement('span'); el.textContent = String(text ?? ''); return el.innerHTML; };
  const districtURL = 'https://sigma.madrid.es/hosted/rest/services/CARTOGRAFIA/LIMITES_ADMINISTRATIVOS/MapServer/3/query?where=1%3D1&outFields=COD_DIS_TX,NOMBRE&outSR=4326&returnGeometry=true&geometryPrecision=5&maxAllowableOffset=0.0001&f=geojson';
  function loadDistricts() {
    if (!districtPromise) {
      const abort = new AbortController(), timer = setTimeout(() => abort.abort(), 12000);
      districtPromise = fetch(districtURL, {signal: abort.signal}).then(r => {
        if (!r.ok) throw new Error('HTTP ' + r.status); return r.json();
      }).then(data => {
        if (data.type !== 'FeatureCollection' || data.features.length !== 21 || data.exceededTransferLimit)
          throw new Error('No contiene los 21 distritos');
        districts = L.geoJSON(data, {
          style: {color: '#89adbe', weight: 1.2, fillColor: '#86a4ad', fillOpacity: .045},
          onEachFeature: (feature, layer) => {
            const name = feature.properties.NOMBRE || feature.properties.COD_DIS_TX;
            layer.bindTooltip(safe(name), {sticky: true});
            layer.bindPopup('<strong>' + safe(name) + '</strong><br>Distrito · Ayuntamiento de Madrid<br>Sin estimación de temperatura por zona.');
            layer.on('mouseover', () => layer.setStyle({weight: 2, fillOpacity: .14}));
            layer.on('mouseout', () => layer.setStyle({weight: 1.2, fillOpacity: .045}));
          }
        });
        map.attributionControl.addAttribution('Distritos: Ayuntamiento de Madrid');
        if (currentRegion === 'madrid') districts.addTo(map).bringToBack();
        document.getElementById('geo-map').dataset.districtCount = String(data.features.length);
        return districts;
      }).catch(() => {
        districtPromise = null;
        if (currentRegion === 'madrid') status('No se han podido cargar los distritos oficiales. Las estaciones siguen disponibles.');
        return null;
      }).finally(() => clearTimeout(timer));
    }
    return districtPromise;
  }
  function update(data) {
    const target = document.getElementById('geo-map'); if (!target) return;
    if (!window.L) { status('Leaflet no está disponible. Comprueba el CDN; consulta las lecturas en la tabla.'); return; }
    if (!map) {
      map = L.map(target, {preferCanvas: true, scrollWheelZoom: false}).setView([40.43, -3.7], 11);
      L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
        subdomains: 'abcd', maxZoom: 19, keepBuffer: 2, updateWhenIdle: true
      }).on('tileerror', () => status('Mapa base no disponible; los puntos y límites conservan sus coordenadas.')).addTo(map);
      stationLayer = L.layerGroup().addTo(map); L.control.scale({imperial: false}).addTo(map);
      new ResizeObserver(() => map.invalidateSize({pan: false})).observe(target);
      window.pulsoMap = map;
    }
    if (currentRegion !== data.region) {
      if (currentRegion) views.set(currentRegion, {center: map.getCenter(), zoom: map.getZoom()});
      currentRegion = data.region; const saved = views.get(data.region);
      map.setView(saved ? saved.center : [data.lat, data.lon], saved ? saved.zoom : data.zoom, {animate: false});
      if (districts) { if (data.region === 'madrid') districts.addTo(map); else map.removeLayer(districts); }
      if (data.region === 'madrid') loadDistricts();
    }
    status(data.mode === 'demo' ? 'DEMO · posiciones y lecturas sintéticas; límites administrativos oficiales.' :
      (data.markers.length ? 'Estaciones oficiales · selecciona un punto; arrastra o usa + / − para explorar.' : 'Sin coordenadas para este indicador. Conecta la fuente o consulta la tabla.'));
    const keep = new Set();
    data.markers.forEach(point => {
      const id = data.region + ':' + point.network + ':' + point.station; keep.add(id);
      const selected = point.station === data.selected;
      const style = {color: selected ? '#ffffff' : '#14242d', weight: selected ? 3 : 1.5,
        fillColor: !point.fresh ? '#8192a6' : point.value >= data.threshold ? '#ff9d6c' : '#c8f36b', fillOpacity: .9};
      let marker = markers.get(id);
      const popup = '<strong>' + safe(point.name) + '</strong><br>' + safe(point.value) + ' ' + safe(data.unit) +
        '<br>' + safe(point.time) + ' · ' + (point.fresh ? 'reciente' : 'antigua') +
        '<br>' + (data.mode === 'demo' ? 'Escenario sintético' : safe(data.provider));
      if (!marker) {
        marker = L.circleMarker([point.lat, point.lon], {radius: selected ? 10 : 7, ...style}).addTo(stationLayer);
        marker.on('click', () => window.Shiny?.setInputValue('map_station', point.station, {priority: 'event'}));
        marker.bindPopup(popup); marker.bindTooltip(safe(point.name)); markers.set(id, marker);
      } else marker.setLatLng([point.lat, point.lon]).setStyle(style).setRadius(selected ? 10 : 7).setPopupContent(popup);
    });
    markers.forEach((marker, id) => { if (!keep.has(id)) { stationLayer.removeLayer(marker); markers.delete(id); } });
    target.dataset.stationCount = String(markers.size); map.invalidateSize({pan: false});
  }
  function register() { if (window.Shiny) Shiny.addCustomMessageHandler('pulso-map', update); }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', register); else register();
})();
