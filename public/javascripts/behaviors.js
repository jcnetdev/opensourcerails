$j(document).ready(function() {
  
  // Wire up Switch to First Buttons on tabs
  $j(".tabs .switch-to-first").livequery("click", function() {
    $j(this).parents(".tabs").find("ul").tabs('select', 0);
    return false;
  });
  
  // Wire up Switch to Last Buttons on tabs
  $j(".tabs .switch-to-last").livequery("click", function() {
    $tabsElement = $j(this).parents(".tabs").find("ul");
    $tabsElement.tabs('select', $tabsElement.tabs("length")-1);
    return false;
  });
  
  // Allow any link with "toggle" to hide and show a particular element
  $j("a.toggle").livequery('click', function() {
    $this = $j(this); 
    $j($this.attr("rel")).slideToggle();  
    return false;
  });
  
  // Allow any link with "toggle" to hide and show a particular element
  $j("a.hide-click").livequery('click', function() {
    $this = $j(this); 
    $j($this.attr("rel")).slideUp();  
    return false;
  });
  
  // Add example text
  $j('.example').livequery(function() {
    $this = $j(this);
    if($this.val() == "")
    {
      $this.example($this.attr("title"));
    }
  }, function() {});
  
  // hook up ratings
  $j(".ratings-control").livequery(function() {
    
    $this = $j(this);
    $rateLink = $j(this).find("a.rate-init");
    
    // get configuration for rating
    rating = parseInt($rateLink.text());
    rateUrl = $rateLink.attr("href");

    // clear out contents
    $this.empty();

    new Control.Rating(this, {
      max: 5,
      afterChange: function(value) {
        console.log("RATED AS "+value);
        $this.removeAttr("title");
      },
      value: rating,
      multiple: true,
      capture: true,
      updateParameterName: "rating",
      updateUrl: rateUrl
    });
    
  },function() {});
  
  
  // wire up ajax-forms
  $j('form.ajax-form').livequery(function(){
    $j(this).ajaxForm({data: {format: "ajax"}, target: $j(this).parents(".form-container")});
  }, function(){ });

  $j('form.ajax-form').livequery("submit", function(){
    $j(this).find(".progress").show();
  }, function(){ });
  
  // wire up add screenshot field
  $j(".add-screenshot-field").livequery("click", function() {
    $input = $j(this).parents("form").find(".field input:last");
    
    $clone = $input.clone();
    $clone.val("");
    $input.after($clone);
    
    return false;
  });  

  // update bookmarks
  function updateBookmarkPanel() {
    $j("#my_bookmarks").load("/bookmarks?format=ajax");
  };
  
  // hook up bookmarking minipanel
  $j(".bookmark-mini").livequery(function() {
    
    $panel = $j(this);
    $panel.find(".bookmark-button").removeAttr("onclick");
    $panel.find(".bookmark-button").click(function(e) {
      e.preventDefault();
      $button = $j(this);
      if($button.is(".add"))
      {
        // handle add bookmark ajax call
        $j.post($button.attr("href"), "format=ajax", function(data) {
          $button.parents(".bookmark-mini").replaceWith($j(data));
          updateBookmarkPanel();
        });
      }
      else
      {
        // handle remvoe ajax call
        $j.post($button.attr("href"), "format=ajax&_method=delete", function(data) {
          $button.parents(".bookmark-mini").replaceWith($j(data));
          updateBookmarkPanel();
        });        
      }
    });
    
  }, function() {})

});