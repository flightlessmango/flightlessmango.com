require("chartkick").use(require("highcharts"))
import Highcharts from 'highcharts';
addExporting(Highcharts)
window.Highcharts = Highcharts;
import addExporting from "highcharts/modules/exporting";
import addBoost from "highcharts/modules/boost";
require("packs/highcharts-custom.js")