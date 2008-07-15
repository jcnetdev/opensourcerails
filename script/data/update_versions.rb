#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/environment'

# delete child records
ActiveRecord::Base.connection.execute "DELETE FROM versions WHERE project_id IS NULL"

# transfer screenshots
ActiveRecord::Base.connection.execute "UPDATE versions SET "+
                                      "download_file_name=filename, "+
                                      "download_file_size=size, "+
                                      "download_content_type=content_type "

Project.all.each do |project|
  
  v = project.versions.first
  
  if v
    project.download_url = v.download.url
    project.save
  end
  
end