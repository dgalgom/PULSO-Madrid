// Deterministic browser integration: real Leaflet code, synthetic district fixture.
const {chromium} = require('playwright');
const fs = require('node:fs');
const assert = require('node:assert/strict');
let failurePage;
(async () => {
  const browser = await chromium.launch({headless: true});
  const page = await browser.newPage({viewport: {width: 1500, height: 1100}});
  failurePage = page;
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  await page.route('**/leaflet@1.9.4/dist/leaflet.js', route => route.fulfill({path: require.resolve('leaflet/dist/leaflet.js'), contentType: 'application/javascript'}));
  await page.route('**/leaflet@1.9.4/dist/leaflet.css', route => route.fulfill({path: require.resolve('leaflet/dist/leaflet.css'), contentType: 'text/css'}));
  const fixture = {type: 'FeatureCollection', features: Array.from({length: 21}, (_,i) => {
    const x = -3.78 + (i % 7) * .025, y = 40.38 + Math.floor(i / 7) * .04;
    return {type: 'Feature', properties: {NOMBRE: 'TEST distrito ' + i}, geometry: {type: 'Polygon', coordinates: [[[x,y],[x+.02,y],[x+.02,y+.03],[x,y+.03],[x,y]]]}};
  })};
  await page.route('**/LIMITES_ADMINISTRATIVOS/MapServer/3/query?*', route => route.fulfill({json: fixture}));
  await page.goto('http://127.0.0.1:3838', {waitUntil: 'domcontentloaded'});
  await page.waitForFunction(() => document.getElementById('geo-map')?.dataset.stationCount === '8', {timeout: 30000});
  await page.waitForFunction(() => document.getElementById('geo-map')?.dataset.districtCount === '21');
  await page.waitForSelector('#climate_result .climate-values');
  assert.match(await page.locator('#climate_result').innerText(), /2006–2025/);
  assert.match(await page.locator('#climate_result').innerText(), /SINTÉTICOS/);
  const selected = await page.locator('#station').inputValue();
  await page.evaluate(selected => {
    let clicked = false;
    window.pulsoMap.eachLayer(layer => { if (!clicked && layer instanceof L.LayerGroup) layer.eachLayer(marker => {
      if (!clicked && marker instanceof L.CircleMarker && marker.options.stationId !== selected) { marker.fire('click'); clicked = true; }
    }); });
  }, selected);
  await page.waitForFunction(selected => document.querySelector('#station').value !== selected,selected);
  const before = await page.evaluate(() => { window._originalMap = window.pulsoMap; return window.pulsoMap.getZoom(); });
  const filterStart = Date.now();
  await page.selectOption('#metric','pm25');
  await page.waitForFunction(() => document.getElementById('geo-map').dataset.metric === 'pm25');
  console.log('Observed local filter-to-map update:',Date.now()-filterStart,'ms (synthetic browser fixture; not provider latency).');
  assert.equal(await page.evaluate(() => window.pulsoMap === window._originalMap), true, 'map instance survives filtering');
  assert.equal(await page.evaluate(() => window.pulsoMap.getZoom()), before, 'zoom survives filtering');
  await page.selectOption('#region','galicia');
  await page.waitForFunction(() => document.getElementById('geo-map').dataset.stationCount === '0');
  await page.waitForFunction(() => document.getElementById('data_notice').innerText.includes('SIN CARGAR'));
  assert.match(await page.locator('#data_notice').innerText(), /SIN CARGAR/);
  await page.selectOption('#region','catalunya');
  await page.waitForFunction(() => document.querySelector('#metric').value === 'no2');
  await page.selectOption('#region','madrid');
  await page.waitForFunction(() => document.getElementById('geo-map').dataset.stationCount === '8');
  await page.selectOption('#metric','temperature');
  fs.mkdirSync('validation-output',{recursive:true});
  await page.screenshot({path:'validation-output/desktop-test-fixture.png',fullPage:true});
  await page.setViewportSize({width:390,height:844});
  await page.waitForTimeout(300);
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1),true,'no mobile horizontal overflow');
  await page.screenshot({path:'validation-output/mobile-test-fixture.png',fullPage:true});
  assert.deepEqual(errors,[],'no browser JavaScript errors');
  await browser.close();
  console.log('Browser checks passed: Leaflet, 21 fixture zones, station input, persistent map/zoom, regional empty states, daily baseline panel, desktop/mobile.');
})().catch(async e => {
  console.error(e); fs.mkdirSync('validation-output',{recursive:true});
  if(failurePage) {
    console.error('Page status:',await failurePage.locator('#data_notice').innerText().catch(()=>''));
    await failurePage.screenshot({path:'validation-output/browser-failure-test-fixture.png',fullPage:true}).catch(()=>{});
  }
  process.exit(1);
});
