#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

require 'fileutils'
Screenshot.find(981).destroy
Screenshot.find(:all, :conditions => "thumbnail IS NULL").each do |screen|
  
  FileUtils.mkdir_p("#{RAILS_ROOT}/public/screenshots_new/#{screen.id}/original/")
  FileUtils.mkdir_p("#{RAILS_ROOT}/public/screenshots_new/#{screen.id}/medium/")
  FileUtils.mkdir_p("#{RAILS_ROOT}/public/screenshots_new/#{screen.id}/thumb/")

  # copy original
  FileUtils.cp("#{RAILS_ROOT}/public/screenshots/#{screen.id}/#{screen.filename}", 
               "#{RAILS_ROOT}/public/screenshots_new/#{screen.id}/original/#{screen.filename}")
  
  # copy medium
  list_thumbnail = screen.thumbnails.select{|x| x.thumbnail == "list"}.first
  FileUtils.cp("#{RAILS_ROOT}/public/screenshots/#{screen.id}/#{list_thumbnail.filename}", 
               "#{RAILS_ROOT}/public/screenshots_new/#{screen.id}/medium/#{screen.filename}")

  # copy thumb
  thumb_thumbnail = screen.thumbnails.select{|x| x.thumbnail == "thumb"}.first
  FileUtils.cp("#{RAILS_ROOT}/public/screenshots/#{screen.id}/#{thumb_thumbnail.filename}", 
               "#{RAILS_ROOT}/public/screenshots_new/#{screen.id}/thumb/#{screen.filename}")
  
end