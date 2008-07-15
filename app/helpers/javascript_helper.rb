module JavascriptHelper
  
  # Add javascripts to page
  def javascripts(options = {})
    [
      prototype,
      jquery,

      javascript_tag("$j = jQuery.noConflict();"),
      javascript(include_javascripts("jquery.ext")),
      javascript(include_javascripts("libraries")),
      javascript(include_javascripts("common")),
      javascript(include_javascripts("components")),
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
    if AppConfig.minimize
      javascript("jquery.min.js")
    else
      javascript("jquery")
    end
  end
  
  # returns a list of *css file paths* for a sass directory
  def include_javascripts(path)
    if AppConfig.minimize
      "min/#{path}.js"
    else
      # Good for debugging
      javascript_list = Dir["#{RAILS_ROOT}/public/javascripts/#{path}/*.js"]

      result = []
      javascript_list.each do |javascript|
        result << javascript.gsub("#{RAILS_ROOT}/public/javascripts/", "")
      end
  
      return result
    end
  end
  
end