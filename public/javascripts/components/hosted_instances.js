
// handle screenshot add form
$j(document).ready(function() {
  if($j("#hosted_instances_add").notOnPage()){return;}

  $j("#hosted_instances_add form").submit(function() {
    var isSuccess = true;

    // reset errors
    $j("#hosted_instances_add .field").removeClass("withErrors");
    
    // Do some validation the long way. I really should be using a validation plugin or something
    if($j("#hosted_instances_add #hosted_instance_title").val() == "")
    {
      isSuccess = false;
      $j("#hosted_instances_add #hosted_instance_title").parents(".field").addClass("withErrors");
    }
    if($j("#hosted_instances_add #hosted_instance_url").val() == "")
    {
      isSuccess = false;
      $j("#hosted_instances_add #hosted_instance_url").parents(".field").addClass("withErrors");
    }
    if($j("#hosted_instances_add #hosted_instance_antispam").val() == "")
    {
      isSuccess = false;
      $j("#hosted_instances_add #hosted_instance_antispam").parents(".field").addClass("withErrors");
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
