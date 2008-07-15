class Screenshot < ActiveRecord::Base  
  include Mixins::ProjectItem
  
  # allow image attachments
  has_attachment :content_type => :image,
                 :max_size => 1.megabytes,
                 :thumbnails => { :thumb => 70, :list => 225 },
                 :storage => :s3,
                 :processor => :mini_magick
  
  validates_as_attachment
      
end
