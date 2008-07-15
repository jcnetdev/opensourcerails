#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/environment'

# delete child records
ActiveRecord::Base.connection.execute "DELETE FROM screenshots WHERE project_id IS NULL"

# transfer screenshots
ActiveRecord::Base.connection.execute "UPDATE screenshots SET "+
                                      "screenshot_file_name=filename, "+
                                      "screenshot_file_size=size, "+
                                      "screenshot_content_type=content_type"
                                      
Project.all.each do |project|
  
  s = project.screenshots.first
  
  if s
    project.screenshot_url = s.screenshot.url
    project.thumb_url = s.screenshot.url(:thumb)
    project.preview_url = s.screenshot.url(:medium)
    project.save
  end
  
end