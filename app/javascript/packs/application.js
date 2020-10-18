// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("jquery")
require("@rails/ujs").start()
window.jQuery = $;
window.$ = $;
require("bootstrap")
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("chartkick").use(require("highcharts"))
import Highcharts from 'highcharts';
addExporting(Highcharts)
window.Highcharts = Highcharts;
import addExporting from "highcharts/modules/exporting";
import addBoost from "highcharts/modules/boost";
import '../stylesheets/application'
import toastr from 'toastr';
import '../stylesheets/colorPick'
require("packs/highcharts-custom.js")
require("packs/colorPick.js")
require("packs/custom.js")
require("packs/google_analytics.js.erb")

toastr.options = {
    "closeButton": true
};

global.toastr = toastr;

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


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
