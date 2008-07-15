$j(document).ready(function() {
  // make clicking on a Flash Message fade it away
  $j('div.flash').click(function() {
    Effect.Fade($(this));
  });
  
  if($j("div.flash").is(":visible"))
  {
    // remove flash panel after 5 seconds
    setTimeout(function() {
      $j('div.flash').slideUp()
    }, 6000)
  }
});
