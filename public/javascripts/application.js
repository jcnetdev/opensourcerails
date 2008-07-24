$j(document).ready(function() {
  // Add javascript here
  
  $j(".tabs > ul").tabs();
  
  // Handle the hide about section
  $j("a.hide-about").click(function() {
    $j("#about_us").slideUp();  
    $j(".about a").fadeIn();
    return false;
  });
  
  
  $j('.dragscroll').each(function(index) {
    new DragScrollable(this);
  });
  
});

// handle corners
$j(document).ready(function() {
  var cornerarg = "15px Hover";
  
  if($j.browser.msie && $j.browser.version >= 7)
  {
    $j(window).load(function() {
      $j(".rounded").corner(cornerarg);
    });
  }
  else
  {
    $j(".rounded").corner(cornerarg);    
  }

});