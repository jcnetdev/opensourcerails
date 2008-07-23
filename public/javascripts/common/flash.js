$j(document).ready(function() {
  // make clicking on a Flash Message fade it away  
  $j('div.flash a.close-text').click(function() {
    Effect.Fade($(this).up());
    return false;
  });
});
