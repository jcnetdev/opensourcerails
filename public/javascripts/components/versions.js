
// handle screenshot add form
$j(document).ready(function() {
  if($j("#versions_add").notOnPage()){return;}

  $j("#versions_add .set-upload").click(function() {
    $j("#versions_add .attach-link").hide();
    $j("#versions_add .attach-link input").val("");
    $j("#versions_add .attach-download").show();
    return false;
  });
  
  $j("#versions_add .set-link").click(function() {
    $j("#versions_add .attach-download").hide();
    $j("#versions_add .attach-download input").val("");
    $j("#versions_add .attach-link").show();
    return false;
  });

  $j("#versions_add form").submit(function() {
    var isSuccess = true;

    // reset errors
    $j("#versions_add .field").removeClass("withErrors");
    
    // Do some validation the long way. I really should be using a validation plugin or something
    if($j("#versions_add #version_title").val() == "")
    {
      isSuccess = false;
      $j("#versions_add #version_title").parents(".field").addClass("withErrors");
    }

    // see if we should allow the form to submit
    if(isSuccess)
    {
      $j(this).find(".progress").show();
      return true;
    }
    else
    {
      return false;
    }    
  });
});
