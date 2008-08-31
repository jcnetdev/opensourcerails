# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  before_filter :check_login, :only => [:new, :create]
  helper_method :openid_error?
  
  # render new.rhtml
  def new
  end

  def create
    if using_open_id? or params["use_openid"] == "true"
      open_id_authentication(params[:openid_url])
    else
      password_authentication
    end
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  def show
    if logged_in?
      redirect_to user_url(current_user)
    else
      redirect_to root_url
    end
  end
  
  def index
    redirect_to session_url
  end
  
  private
  def check_login
    if logged_in?
      redirect_to session_url
      return false
    end
  end
  protected
  def password_authentication
    @login = Login.new(params[:login])
    self.current_user = User.login_with(@login)
	    
    if logged_in?
      if @login.remember_me?
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:success] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def open_id_authentication(openid_url)
    authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
      if result.successful?
        @openid_user = User.find_or_initialize_by_identity_url(identity_url)
        if @openid_user.new_record?
          @openid_user.login = registration['nickname']
          @openid_user.login = "anon_" + rand(99999).to_s if @openid_user.login.blank?
          @openid_user.email = registration['email']
          passwd = rand_passwd
          @openid_user.password = passwd
          @openid_user.password_confirmation = passwd
          @openid_user.ip_address = request.remote_ip
          @openid_user.save!
        end
        self.current_user = @openid_user
        successful_login
      else
        failed_login result.message
      end
    end
  end
  
  def openid_error?
    !@openid_error.blank?
  end
    
  private
  def successful_login
    session[:user_id] = self.current_user.id
    flash[:success] = "Logged in successfully"    
    redirect_back_or_default('/')
    #    redirect_to(root_url)
  end

  def failed_login(message)
    @openid_error = message
    render :action => "new"
    return false
  end
  
  def rand_passwd(limit = 6)
    (('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a - %w(o i l 0 1)).sort_by{rand}.join[0,limit]
  end
end
