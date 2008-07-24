module StylesheetHelper
  
  def stylesheets(options = {})
    [
      stylesheet("blueprint", "util", "forms", "application", :cache => "base-cache"),
      stylesheet(include_css("v2")),

      page_stylesheets(options)
    ].join("\n")
    
  end
  
  # returns a recursive list of *css file paths* for a sass directory
  def include_css(path)
    if !AppConfig.force_all_css and (use_cache? or browser_is? :ie)
      "min/#{path}.css"
    else
      result = []
      Dir["#{RAILS_ROOT}/public/stylesheets/#{path}/**/*.css"].each do |css|
        result << css.gsub("#{RAILS_ROOT}/public/stylesheets/", "")
      end
      return result
    end
  end
end