// screenshots
$j(document).ready(function() {
  if($j("#screenshots").notOnPage()){return;}

  $j("#screenshots .screenshot").hover(function() {
    $j(this).find(".delete").show();
  }, function() {
    $j(this).find(".delete").hide();
  });


  $j("#view_slideshow_link").click(function() {
    if($j(".lightview").onPage())
    {
      Lightview.show($j(".lightview").get(0));
    }
    return false;
  });
  
  $j("#main_screenshot").click(function(e) {
    e.preventDefault();

    $findScreen = $j(".lightview[href='"+$j(this).attr("href")+"']");
    if($findScreen.onPage())
    {
      Lightview.show($findScreen.get(0));
    }
  });
  
  // observe lightview events
  $('screenshots').observe('lightview:opened', function(event) {
    $j(".lv_Data .lv_ChangeDefault").remove();
    
    $findScreen = $j(".lightview[href='"+$j(event.target).attr("href")+"']");
    if($findScreen.onPage())
    {
      switchDefault = $findScreen.parents(".screenshot").find(".switch-default .lv_Button").get(0);
      $j("<li class='lv_ChangeDefault'></li>").append(switchDefault).appendTo(".lv_Data");
    }
  });

});

// handle screenshot add form
$j(document).ready(function() {
  if($j("#screenshots_add").notOnPage()){return;}

  $j("#screenshots_add form").submit(function() {
    $j(this).find(".progress").show();
  });
});
