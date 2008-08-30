class TellFriend < ActiveRecord::BaseWithoutTable
  column :to, :string
  column :from, :string
  column :subject, :string
  column :message, :text
  
  validates_as_email_address :to, :from
  
  attr_accessor :error_message
  
  def send_msg(user)
    if self.valid?
      UserMailer.deliver_tell_friend(user, self)
      
      # incremement
      user.tell_friend_count += 1
      user.tell_friend_last_sent = Time.now
      user.save
      
      return true
    else
      return false
    end
  end
  
end