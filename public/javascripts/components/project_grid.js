$j(document).ready(function() {
  if($j("#project_grid").notOnPage()){return;}
  
  // hook up ajax paging
  $j("#project_grid .pagination a").livequery('click', function() {
    $j("#project_grid").load($j(this).attr("href")+"&ajax=true");    
    return false;
  });
  
  // wire up our ajax progress (just hides and shows .progress)
  $j.ajaxSetup({
    beforeSend: function() {
      $j("#project_grid .note").hide();
      $j("#project_grid .loading").show();
    },
    complete: function() {
      $j("#project_grid .loading").hide();
      $j("#project_grid .note").show();
    }
  });  
  
  // Allow ESC to show debug information
  shortcut.add("LEFT",function() {
    $j("#project_grid .pagination *:first-child").click();
  });
  shortcut.add("RIGHT",function() {
    $j("#project_grid .pagination *:last-child").click();
  });

  // Set tooltips
  $j("#project_grid .pagination *:first-child").attr("title", "Shortcut: LEFT ARROW");
  $j("#project_grid .pagination *:last-child").attr("title", "Shortcut: RIGHT ARROW");
  
});