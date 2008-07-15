class Version < ActiveRecord::Base
  include Mixins::ProjectItem
  
  # allow attachments
  has_attachment :max_size => 10.megabytes,
                 :storage => :s3

  validates_presence_of :title
  validates_as_attachment
  
  after_save :set_project_download_url
  
  # check if a version is the project's default
  def is_default?
    if self.project and self.project.download_url == self.public_filename
      return true
    else
      return false
    end
  end
  
  protected
  def set_project_download_url
    if self.project and self.project.owner == self.owner
      self.project.update_attribute("download_url", self.public_filename) 
    end
  end
end
