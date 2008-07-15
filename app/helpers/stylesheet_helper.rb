module StylesheetHelper
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
      ["application", include_sass("common"), include_sass("components")]
    end
  end

  # returns a list of *css file paths* for a sass directory
  def include_sass(path)
    # include common and component sass
    sass_styles = Dir["#{RAILS_ROOT}/public/stylesheets/sass/#{path}/*.sass"]

    # convert to css paths
    css_styles = []
    sass_styles.each do |sass_path|
      css_path = sass_path.gsub("#{RAILS_ROOT}/public/stylesheets/sass/", "").gsub(".sass", ".css")
      css_styles << css_path 
    end
  
    return css_styles
  end
end