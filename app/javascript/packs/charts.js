require("chartkick").use(require("highcharts"))
import Highcharts from 'highcharts';
addExporting(Highcharts)
window.Highcharts = Highcharts;
import addExporting from "highcharts/modules/exporting";
import addBoost from "highcharts/modules/boost";
require("packs/highcharts-custom.js")

Highcharts.wrap(Highcharts.Chart.prototype, 'setReflow', function(proceed, reflow) {
    var chart = this;
      proceed.call(this, reflow);
      if (reflow !== false && typeof ResizeObserver === 'function') {
          // Unbind window.onresize handler so we don't do double redraws
          if (this.unbindReflow) {
            this.unbindReflow();
          }
          var ro = new ResizeObserver(function () {
              chart.reflow();
          });
          ro.observe(this.renderTo);
      }
  });