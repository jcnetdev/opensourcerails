module Blog
  class Post < WordpressModel
    set_table_name "wp_posts"
    
    named_scope :posts, 
                :conditions => "post_type = 'post' AND post_status != 'draft' AND post_status != 'static'", 
                :order => "post_date DESC"
    
  end
end