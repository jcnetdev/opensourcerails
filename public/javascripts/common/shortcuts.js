// Use this file to define keyboard shortcuts for our web app
$j(document).ready(function() {
  
  // Allow ESC to show debug information
  shortcut.add("ESC",function() {
    $j(".container.debug").toggleClass("showgrid");
    $j(".debug-info.container").toggle();
  });
  

});