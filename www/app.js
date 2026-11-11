// Delegation survives Shiny renderUI replacements. SVG points work by keyboard.
(() => {
  function selectStation(event) {
    const point = event.target.closest('.station-point');
    if (!point) return;
    if (event.type === 'keydown' && !['Enter', ' '].includes(event.key)) return;
    event.preventDefault();
    if (window.Shiny) Shiny.setInputValue('map_station', point.dataset.station, {priority: 'event'});
  }
  document.addEventListener('click', selectStation);
  document.addEventListener('keydown', selectStation);
})();
