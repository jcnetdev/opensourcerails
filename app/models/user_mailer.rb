class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)

    subject "#{AppConfig.site_name} - Please activate your new account"  
    body  :user => user,
          :url => "#{AppConfig.site_url}/users/#{user.activation_code}/activate"
  end
  
  def activation_success(user)
    setup_email(user)
    subject "#{AppConfig.site_name} - Your account has been activated!"
    body :user => user,
         :url => "#{AppConfig.site_url}"
  end
  
  def send_password_reset(user)
    setup_email(user)
    
    subject "#{AppConfig.site_name} Password Recovery"
    body :user => user
  end
  
  protected
    def setup_email(user)
      recipients  "#{user.email}"
      from  "Admin"
      sent_on Time.now
    end
end
