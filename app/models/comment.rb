class Comment < ActiveRecord::Base
  include Mixins::ProjectItem
    
  validates_presence_of :body
  validates_presence_of :author_name, :author_email
  validates_as_email_address :author_email, :allow_blank => true
  
  
  belongs_to :user, :class_name => "User", :foreign_key => "owner_id"
  
  def self.initialize_from_user(user)
    comment = Comment.new
    if user.is_a? User
      comment.author_name = user.to_s
      comment.author_email = user.email
    end
    
    return comment
  end
end
