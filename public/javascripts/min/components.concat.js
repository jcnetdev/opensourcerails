/* ---- Compressing ./public/javascripts/components/about_project.js ----- */
$j(document).ready(function() {
  $j('#about_project .cancel').livequery("click", function(){
    $j(this).parents(".form-container").slideUp('slow');
    $j("#project_info .display").slideDown('slow');
    $j("#project_info .edit").fadeIn()
    return false;
  });
  
  // wire up ajax links
  $j('#project_info .edit').livequery("click", function(){
    $this = $j(this);

    $j("#project_info .display").slideUp('slow')
    $j("#project_info .form-container").load($this.attr("href")+"?format=js", null, function() {
      $j(this).slideDown('slow');
    });
    $this.fadeOut();
    return false;
  });

  // wire up ajax links
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

/* ---- Compressing ./public/javascripts/components/about_user.js ----- */
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
    $j("#about_user .form-container").load($this.attr("href")+"?format=js", null, function() {
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
      $reload.load(reload_url, null, function() {
        $j("#about_user").slideDown('slow');        
      });
    })
    return false;
  });

  
});

/* ---- Compressing ./public/javascripts/components/hosted_instances.js ----- */

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

/* ---- Compressing ./public/javascripts/components/project_grid.js ----- */
$j(document).ready(function() {
  if($j("#project_grid").notOnPage()){return;}
  if($j("#disable_ajax_paging").onPage()){return;}
  
  
  $j("#project_grid .note").show();

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
  }, {disable_in_input: true});
  shortcut.add("RIGHT",function() {
    $j("#project_grid .pagination *:last-child").click();
  }, {disable_in_input: true});

  // Set tooltips
  $j("#project_grid .pagination *:first-child").attr("title", "Shortcut: LEFT ARROW");
  $j("#project_grid .pagination *:last-child").attr("title", "Shortcut: RIGHT ARROW");
  
});

/* ---- Compressing ./public/javascripts/components/projects_add.js ----- */


/* ---- Compressing ./public/javascripts/components/screenshots.js ----- */
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

/* ---- Compressing ./public/javascripts/components/versions.js ----- */

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

