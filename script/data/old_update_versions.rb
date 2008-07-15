#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

require 'fileutils'


Version.find(:all, :conditions => "project_id IS NOT NULL").each do |version|
  
  FileUtils.mkdir_p("#{RAILS_ROOT}/public/downloads/#{version.id}/original/")

  # copy original
  FileUtils.cp("#{RAILS_ROOT}/public/versions/#{version.id}/#{version.filename}", 
               "#{RAILS_ROOT}/public/downloads/#{version.id}/original/#{version.filename}")
  

end