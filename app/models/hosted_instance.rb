class HostedInstance < ActiveRecord::Base
  include Mixins::ProjectItem
  
  validates_presence_of :title
  validates_presence_of :url  
  
  before_save :prepend_urls
  
  protected
  
  # check the urls for a valid prefix, and if append http:// if necessary
  def prepend_urls    
    unless check_url(self.url)
      self.url = "http://#{self.url}"
    end
  end
  
  def check_url(url)
    url.blank? ||
    url =~ /http\:\/\// || 
    url =~ /https\:\/\// || 
    url =~ /mailto\:/ 
  end
end
