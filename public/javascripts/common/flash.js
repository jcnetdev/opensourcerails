$j(document).ready(function() {
  // make clicking on a Flash Message fade it away
  $j('div.flash').click(function() {
    Effect.Fade($(this));
  });
});
