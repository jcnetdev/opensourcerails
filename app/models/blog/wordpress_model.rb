# http://wpbits.wordpress.com/2007/08/08/a-look-inside-the-wordpress-database/

module Blog
  class WordpressModel < ActiveRecord::Base
    use_db :prefix => "blog_"
    
  end
end