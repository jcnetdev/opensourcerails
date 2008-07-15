// screenshots
$j(document).ready(function() {
  if($j("#screenshots").notOnPage()){return;}

  $j("#screenshots .screenshot").hover(function() {
    $j(this).find(".delete").show();
  }, function() {
    $j(this).find(".delete").hide();
  });

  // handle screenshot clicks
  $j("#screenshots .screenshot a.show-screen").click(function() {
    $this = $j(this);
    
    // start the progress indicator
    $j(".image-loading").show();
    
    $j("#current_screenshot").fadeOut();

    // replace the view photo link
    $j("#current_screenshot_link").attr("href", $this.attr("href"));

    // set up the switch screenshot action
    $j("#current_screenshot_switch").show()
      .find("a")
      .attr("href", $this.parent().find("a.switch-default").attr("href"));
    
    var img = new Image();
    $j(img)
      .load(function() {
        $j(this).hide();
        $j("#current_screenshot").replaceWith(this);
        
        $j(this).attr("id", "current_screenshot");
        
        // start the progress indicator
        $j(".image-loading").hide();
        $j("#current_screenshot").fadeIn();
        
      })
      .attr("src", $this.attr("href"));
      
    
    return false;
  });
  
});

// handle screenshot add form
$j(document).ready(function() {
  if($j("#screenshots_add").notOnPage()){return;}

  $j("#screenshots_add form").submit(function() {
    $j(this).find(".progress").show();
  });
});
