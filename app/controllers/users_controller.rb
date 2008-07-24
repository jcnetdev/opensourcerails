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
    @user = find_user
    @bookmarked_projects = @user.projects
    @submitted_projects = @user.submitted
    @activities = @user.activities.all(:limit => 101, :order => "created_at DESC")
    @rated_projects = @user.rated_projects
    
    respond_to do |format|
      format.html
      format.js do
        render :partial => "users/parts/about_user", :locals => {:user => @user}, :layout => false
      end
    end
  end
  
  def edit
    @user = find_user
    return unless verify_owner(@user)

    respond_to do |format|
      format.html
      format.js do
        render :partial => "users/form", :locals => {:user => @user, :ajax => true}, :layout => false
      end
    end
  end
  
  def edit_password
    @user = find_user
    return unless verify_owner(@user)

    respond_to do |format|
      format.html
      format.js do
        render :partial => "users/parts/password_form", :locals => {:user => @user, :ajax => true}, :layout => false
      end
    end
  end
  
  def update
    @user = find_user
    return unless verify_owner(@user)
    
    @user.attributes = params[:user]
    @user.signed_up = true
    @user.name = params[:user][:name]
    @user.profile = params[:user][:profile]
    
    if @user.save
      if @user.password.blank?
        flash[:success] = "Your profile has been updated."
      else
        flash[:success] = "Your password has been changed."
      end
    else
      error_msg = ""
      error_msg << "<ul class='error'>"
      @user.errors.each do |key, error|
        error_msg << "<li>#{key.capitalize} Field: #{error}</li>"
      end
      error_msg << "</ul>"

      flash[:error] = error_msg
    end
    
    respond_to do |format|
      format.js do
        render :partial => "users/parts/ajax_result.html.haml", :locals => {:message => (flash[:error] || flash[:success])}
        flash.discard
      end
      format.html do
        redirect_to @user
      end
    end
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
  
  # verify that the current user can edit this profile
  def verify_owner(user)
    if user and user == current_or_anon_user
      return true
    else      
      # render an output
      respond_to do |format|        
        flash[:error] = "You don't have access to edit this profile."
        format.js do
          render :text => flash[:error], :layout => false
          flash.discard
        end
        format.html do
          redirect_to user
        end
      end
      return false
    end
  end
  
end
