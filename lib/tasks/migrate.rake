require 'rubygems'
require 'rake'

class Rake::Task
  def add_task_after(&block)
    enhance(&block)
  end
end

# Overwrite migrate task
Rake::Task["db:migrate"].add_task_after do
  puts "Running DB Seed..."
  
  Rake::Task["db:seed"].invoke
end
# 
# task :wtf => :environment do
#   puts Rails.env
# end