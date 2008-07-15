# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  before_filter :check_login, :only => [:new, :create]

  # render new.rhtml
  def new
    @login = Login.new
  end

  def create
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
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  def show
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
end
