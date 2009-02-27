Gem::Specification.new do |s|
  s.name = 'acts_as_state_machine'
  s.version = '2.1.20080704'
  s.date = '2008-07-04'
  
  s.summary = "Allows ActiveRecord models to define states and transition actions between them"
  s.description = "This act gives an Active Record model the ability to act as a finite state machine (FSM)."
  
  s.authors = ['Jacques Crocker', 'Scott Barron']
  s.email = 'railsjedi@gmail.com'
  s.homepage = 'http://github.com/jcnetdev/acts_as_state_machine'
  
  s.has_rdoc = false
  # s.rdoc_options = ["--main", "README"]
  #s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]

  s.add_dependency 'activerecord', ['>= 2.0']
  
  s.files = ["CHANGELOG",
             "MIT-LICENSE",
             "README",
             "Rakefile",
             "TODO",
             "acts_as_state_machine.gemspec",
             "init.rb",
             "lib/acts_as_state_machine.rb",
             "rails/init.rb"]

  s.test_files = ["test/fixtures",
                  "test/fixtures/conversations.yml",
                  "test/test_acts_as_state_machine.rb"]
end