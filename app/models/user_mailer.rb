class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user.email)

    subject "#{AppConfig.site_name} - Please activate your new account"  
    body  :user => user,
          :url => "#{AppConfig.site_url}/users/#{user.activation_code}/activate"
  end
  
  def activation_success(user)
    setup_email(user.email)
    subject "#{AppConfig.site_name} - Your account has been activated!"
    body :user => user,
         :url => "#{AppConfig.site_url}"
  end
  
  def send_password_reset(user)
    setup_email(user.email)
    
    subject "#{AppConfig.site_name} Password Recovery"
    body :user => user
  end
  
  def tell_friend(user, friend)
    setup_email(friend.to)
    reply_to friend.from unless friend.from.blank?
    
    subject AppConfig.tellafriend_subject
    body :tell_friend => friend, :current_user => user
    
  end
  
  protected
    def setup_email(to)
      recipients  "#{to}"
      from  "#{AppConfig.admin_email_name} <#{AppConfig.admin_email_address}>"
      sent_on Time.now
    end
end
