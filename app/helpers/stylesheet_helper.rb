module StylesheetHelper
  
  def v2_stylesheets(options = {})
    [
      stylesheet("common/paging"),
      stylesheet("tabs"),    
      stylesheet("project-list"),
      stylesheet("util"),

      stylesheet(include_css("v2")),
      page_stylesheets(options)
    ].join("\n")
    
  end
  
  # include stylesheets
  def stylesheets(options = {})
    [
      stylesheet("blueprint"),
      stylesheet("forms"),
      stylesheet(sass_files),
      page_stylesheets(options)
    ].join("\n")
  end

  # List of Sass FIles
  def sass_files
    if AppConfig.minimize
      ["min/application", "min/common", "min/components"]
    else
      ["application", include_css("common"), include_css("components")]
    end
  end
  
  # returns a recursive list of *css file paths* for a sass directory
  def include_css(path)
    if use_cache? or browser_is? :ie
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