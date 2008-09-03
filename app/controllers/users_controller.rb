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
    
    # register
    @user.register!
        
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:success] = "Thanks for signing up! You are now logged in. We've sent you an email to confirm your email address, which you'll need in order to log in again."
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def show
    @user = find_user    
    @bookmarked_projects = @user.projects.paginate(:page => params[:page], :per_page => AppConfig.bookmarks_per_page)
    @submitted_projects = @user.submitted
    @activities = @user.activities.all(:limit => 101, :order => "created_at DESC")
    @rated_projects = @user.rated_projects
    
    respond_to do |format|
      format.html do
        @grid_title = helpers.pluralize(@user.projects.count, "Bookmarked Project")
      end
      format.ajax do
        if params[:show] == "about"
          render :partial => "users/parts/about_user.html.haml", :locals => {:user => @user}, :layout => false
        else
          render :partial => "projects/parts/grid.html.haml", :locals => {:projects => @bookmarked_projects}, :layout => false
        end
      end
    end
  end
  
  def edit
    @user = find_user
    return unless verify_owner(@user)
    
    render :partial => "users/form.html.haml", :locals => {:user => @user, :ajax => true}, :layout => false
  end
  
  def edit_password
    @user = find_user
    return unless verify_owner(@user)

    render :partial => "users/parts/password_form.html.haml", :locals => {:user => @user, :ajax => true}, :layout => false
  end
  
  def update
    @user = find_user
    return unless verify_owner(@user)
    
    @user.attributes = params[:user]
    @user.signed_up = true
    @user.name = params[:user][:name] if params[:user][:name]
    @user.profile = params[:user][:profile] if params[:user][:profile]
    
    if @user.save
      if @user.password.blank?
        flash[:success] = "Your profile has been updated."
      else
        flash[:success] = "Your password has been changed."
      end
    else
      error_msg = "<ul class='error'>"
      @user.errors.each do |key, error|
        error_msg << "<li>#{key.capitalize} Field: #{error}</li>"
      end
      error_msg << "</ul>"

      flash[:error] = error_msg
    end
    
    render :partial => "users/parts/ajax_result.html.haml", :locals => {:message => (flash[:error] || flash[:success])}
    flash.discard
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
  
  def forgot_password
    if request.post?
      User.forgot_password(params[:email])
      flash[:notice] = "An email has been sent to you that will allow you to reset your password. If you have any problems email us at #{AppConfig.admin_email_address}"
    end
    redirect_to new_session_url
  end
  
  
  # handle resetting user passwords
  def reset_password
    # find user from auth code
    @user = User.find_by_forgot_password_hash(params[:auth])
    unless @user
      flash[:error] = "Reset Password URL was invalid. It may have expired. Please email us at #{AppConfig.admin_email_address} if you are still unable to log in."
      redirect_to new_session_url
      return
    end
    
    # set url to submit back
    @submit_url = reset_password_users_url
    @form_title = "Reset Password"
    
    # handle post
    if request.put? and @user.update_attributes(params[:user])
      @user.forgot_password_hash = nil
      @user.forgot_password_expire = nil
      @user.save
      
      flash[:notice] = "Your password has been reset. You may now log in with your new password."
      redirect_to new_session_url
    end
  end
  
  protected
  def find_user
    if params[:id].to_s.include? "anon_"
      user_id = params[:id].gsub("anon_","").to_i
      @user = User.find_by_id(user_id)
    else
      @user = User.find_by_login(params[:id])
    end
    
    if @user
      return @user
    else
      raise ActiveRecord::RecordNotFound
    end
  end
  
  # verify that the current user can edit this profile
  def verify_owner(user)
    if user and user == current_or_anon_user
      return true
    else      
      # render an output
      respond_to do |format|        
        flash[:error] = "You don't have access to edit this profile."
        format.ajax do
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
