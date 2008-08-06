module JavascriptHelper
  
  # Add javascripts to page
  def javascripts(options = {})
    [
      prototype,
      jquery,

      javascript_tag("$j = jQuery.noConflict();"),
      javascript_folder("jquery.ext"),
      javascript_folder("libraries"),
      javascript_folder("common"),
      javascript_folder("components"),
      page_javascripts(options),
      
      javascript("application"),
      javascript("behaviors")
    ].flatten.join("\n")
  end
  
  # Include prototype
  def prototype
    [
      javascript("prototype"),
      javascript("scriptaculous/scriptaculous")
    ]
  end
  
  # Include JQuery
  def jquery
    if use_cache?
      javascript("jquery.min.js")
    else
      javascript("jquery")
    end
  end
  
end