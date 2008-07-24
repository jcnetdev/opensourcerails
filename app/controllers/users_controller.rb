class UsersController < ApplicationController  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]

  # render new.rhtml
  def new
    if logged_in?
      flash[:notice] = "You are already logged in."
      redirect_to root_url
    else
      @user = anon_user
    end
  end
  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = anon_user || User.new
    @user.attributes = params[:user]
    @user.signed_up = true
    @user.save!
    
    # register user
    @user.register!
        
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:success] = "Thanks for signing up! You are now logged in. We've sent you an email to confirm your email address, which you'll need in order to log in again."
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def show
    @user = User.find(params[:id])
    @bookmarked_projects = @user.projects
    @submitted_projects = @user.submitted
    @activities = @user.activities.all(:limit => 101, :order => "created_at DESC")
    @rated_projects = @user.rated_projects
  end
  
  def edit
    
  end
  
  def update
    
  end

  def spammer
    spammer = User.find(params[:id])
    if spammer
      spammer.is_spammer!
      flash[:success] = "Spammer has been neutralized."
    else  
      flash[:error] = "No such spammer exists."
    end
    
    redirect_to root_url  
  end

  def activate
    self.current_user = params[:id].blank? ? :false : User.find_by_activation_code(params[:id])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:success] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end

protected
  def find_user
    @user = User.find(params[:id])
  end

end
