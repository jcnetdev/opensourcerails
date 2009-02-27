Gem::Specification.new do |s|
  s.name = 'active_record_without_table'
  s.version = '1.1'
  s.date = '2008-07-05'
  
  s.summary = "Allows creation of ActiveRecord models that work without any database backend"
  s.description = "Get the power of ActiveRecord models, including validation, without having a table in the database."
  
  s.authors = ['Jacques Crocker', 'Jonathan Viney']
  s.email = 'railsjedi@gmail.com'
  s.homepage = 'http://github.com/jcnetdev/active_record_without_table'
  
  s.has_rdoc = false
  # s.rdoc_options = ["--main", "README"]
  #s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]

  s.add_dependency 'activerecord', ['>= 2.0']
   
  s.files = ["CHANGELOG",
              "MIT-LICENSE",
              "README",
              "Rakefile",
              "init.rb",
              "rails/init.rb",
              "active_record_without_table.gemspec",
              "lib/active_record_without_table.rb",
              "lib/active_record/base_without_table.rb"]

  s.test_files = ["test/abstract_unit.rb",
                  "test/active_record_base_without_table_test.rb",
                  "test/database.yml"]

end