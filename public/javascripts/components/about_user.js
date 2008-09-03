$j(document).ready(function() {

  $j('#about_user .cancel').livequery("click", function(){
    $j(this).parents(".form-container").slideUp('slow');
    $j("#about_user .display").slideDown('slow');
    $j("#about_user .edit").fadeIn()
    return false;
  });
  
  // wire up ajax links
  $j('#about_user .edit').livequery("click", function(){
    $this = $j(this);

    $j("#about_user .display").slideUp('slow')
    $j("#about_user .form-container").load($this.attr("href"), function() {
      $j(this).slideDown('slow');
    });
    $this.fadeOut();
    return false;
  });

  // wire up ajax links
  $j('#about_user .restore').livequery("click", function(){
    $this = $j(this);
    $reload = $this.parents(".reload");

    var reload_url = $this.attr("href");
    $reload.find("#about_user").slideUp('slow', function() {
      $reload.empty();
      $reload.load(reload_url, function() {
        $j("#about_user").slideDown('slow');        
      });
    })
    return false;
  });

  
});
