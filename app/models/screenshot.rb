class Screenshot < ActiveRecord::Base  
  include Mixins::ProjectItem
  
  # Add Avatar (configured from AppConfig)
  has_attached_file :screenshot,
                    :styles => AppConfig.screenshot_sizes.marshal_dump,
                    :default_url => AppConfig.screenshot_default
  
  validates_attachment_presence :screenshot
  validates_attachment_size :screenshot, :less_than => 750.kilobytes
  
end
