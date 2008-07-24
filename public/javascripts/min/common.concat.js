/* ---- Compressing ./public/javascripts/common/flash.js ----- */
$j(document).ready(function() {
  // make clicking on a Flash Message fade it away  
  $j('div.flash a.close-text').click(function() {
    Effect.Fade($(this).up());
    return false;
  });
});

/* ---- Compressing ./public/javascripts/common/shortcuts.js ----- */
// Use this file to define keyboard shortcuts for our web app
$j(document).ready(function() {
  
  // Allow ESC to show debug information
  shortcut.add("ESC",function() {
    $j(".container.debug").toggleClass("showgrid");
    $j(".debug-info.container").toggle();
  });
  

});

