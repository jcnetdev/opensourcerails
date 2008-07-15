module MetaHelper
  def meta_tags
    %(
      <meta name="keywords" content="#{meta_keywords}" />
      <meta name="description" content="#{meta_description}" />
    )
  end
  
  # Get/Set Meta Keywords
  def meta_keywords(meta_keywords = nil)
    if meta_keywords
      @__meta_keywords = meta_keywords
    else
      @__meta_keywords ||= ""
      @__meta_keywords = AppConfig.default_meta_keywords if @__meta_keywords.blank?
    end
    return @__meta_keywords
  end
  
  # Get/Set Meta Description
  def meta_description(meta_description = nil)
    if meta_description
      @__meta_description = meta_description
    else
      @__meta_description ||= ""
      @__meta_description = AppConfig.default_meta_description if @__meta_description.blank?
    end
    return @__meta_description
  end

  
end