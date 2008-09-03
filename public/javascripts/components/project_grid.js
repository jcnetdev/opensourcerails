$j(document).ready(function() {
  if($j("#project_grid").notOnPage()){return;}
  if($j("#disable_ajax_paging").onPage()){return;}
  
  
  $j("#project_grid .note").show();

  // hook up ajax paging
  $j("#project_grid .pagination a").livequery('click', function() {
    $j("#project_grid").load($j(this).attr("href")+"&format=ajax");
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
  }, {disable_in_input: true});
  shortcut.add("RIGHT",function() {
    $j("#project_grid .pagination *:last-child").click();
  }, {disable_in_input: true});

  // Set tooltips
  $j("#project_grid .pagination *:first-child").attr("title", "Shortcut: LEFT ARROW");
  $j("#project_grid .pagination *:last-child").attr("title", "Shortcut: RIGHT ARROW");
  
});