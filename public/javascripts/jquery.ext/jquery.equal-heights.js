
// Including this script will find all matching divs with class=equal-heights
// and make them the same height
jQuery(document).ready(function() {  
  refreshHeights();
});

function refreshHeights() {
  // Find Max Height
  var max_height = 0
  
  // reset heights
  jQuery(".equal-heights").css("height", "");
  
  // Elements to match height on
  jQuery(".equal-heights").each(function() {
    height = jQuery(this).height();
    if(height > max_height)
    {
      max_height = height;
    }    
  });
    
  jQuery(".equal-heights").each(function() {
    jQuery(this).height(max_height);
  });
}
