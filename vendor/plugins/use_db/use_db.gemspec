Gem::Specification.new do |s|
  s.name = 'use_db'
  s.version = '1.0'
  s.date = '2008-07-27'
  
  s.summary = "Use multiple databases for your active record models"
  s.description = "Easily connect to additional databases"
  
  s.authors = ['David Stevenson']
  s.homepage = 'http://agilewebdevelopment.com/plugins/usedb'
  
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]

  s.add_dependency 'rails', ['>= 2.1']
  
  s.files = ["MIT-LICENSE",
            "README",
            "Rakefile",
            "init.rb",
            "install.rb",
            "lib/migration.rb",
            "lib/override_fixtures.rb",
            "lib/override_test_case.rb",
            "lib/test_model.rb",
            "lib/use_db.rb",
            "lib/use_db_test.rb",
            "uninstall.rb",
            "use_db.gemspec"]
  
end

