$j(document).ready(function() {
  $j('#about_project .cancel').livequery("click", function(){
    $j(this).parents(".form-container").slideUp('slow');
    $j("#project_info .display").slideDown('slow');
    $j("#project_info .edit").fadeIn()
    return false;
  });
  
  // wire up ajax edit functionality
  $j('#project_info .edit').livequery("click", function(){
    $this = $j(this);

    $j("#project_info .display").slideUp('slow')
    $j("#project_info .form-container").load($this.attr("href"), null, function() {
      $j(this).slideDown('slow');
    });
    $this.fadeOut();
    return false;
  });

  // wire up ajax submit functionality
  $j('#project_info .restore').livequery("click", function(){
    $this = $j(this);
    $reload = $this.parents(".reload");

    var reload_url = $this.attr("href");
    $reload.find("#about_project").slideUp('slow', function() {
      $reload.empty();
      $reload.load(reload_url, null, function() {
        $j("#about_project").slideDown('slow');        
      });
    })
    return false;
  });

  
});
