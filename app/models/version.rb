class Version < ActiveRecord::Base
  include Mixins::ProjectItem
  
  has_attached_file :download
  
  
  validates_presence_of :title
  validates_attachment_size :download, :less_than => 10.megabytes, :unless => :has_link?
  # validates_attachment_presence :download, :unless => :has_link?
  
  after_save :set_project_download_url
  
  def has_link?
    !self.link.blank?
  end
  
  # check if a version is the project's default
  def is_default?
    if self.project and self.project.download_url == self.download.url
      return true
    else
      return false
    end
  end
  
  protected
  def set_project_download_url
    if self.project and self.project.owner == self.owner
      self.project.update_attribute("download_url", self.download.url) 
    end
  end
end
