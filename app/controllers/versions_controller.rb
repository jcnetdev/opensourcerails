class VersionsController < Base::ProjectSubpage
  
  def index
    back_to_project
  end
  
  def new
    back_to_project
  end
  
  def create
    unless check_spam(params[:version][:antispam])
      flash[:error] = "You're either a spammer or bad at math. Either way... no link for you!"
      return redirect_to @project
    end
    
    # check original size of versions
    orig_size = @project.versions.size
    
    @version = @project.versions.build(params[:version])
    @version.owner = current_or_anon_user

    if @version.save      
      @project.mark_changed! unless current_or_anon_user.spammer?
      
      if orig_size == 0
        @project.set_default_version(@version)
      end
      
      flash[:success] = "New Application Version was uploaded."
      redirect_to @project
    else
      flash[:error] = "Unable to Save Version. " + @version.errors.map{|error| "#{error.first.capitalize} #{error.last}"}.join(",")
      redirect_to project_url(@project)+"#versions_add"
    end
  end  
  
  def show
    @version = get_version
    return unless version_exists?(@version)
      
    # increment download count if its the default url
    if @version.download.url == @project.download_url
      @project.increment_downloads
    end
    
    if @version.has_link?
      redirect_to @version.link
    else
      redirect_to @version.download.url
    end
  end
  
  def edit
    @version = get_version
    return unless version_exists?(@version)
    return unless verify_user_access(@version)
    
  end
  
  def update
    @version = get_version
    return unless version_exists?(@version)
    return unless verify_user_access(@version)
    
    if @version.update_attributes(params[:version])
      flash[:notice] = "Version Updated"
      back_to_project
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @version = get_version
    return unless version_exists?(@version)
    return unless verify_user_access(@version)
    
    flash[:notice] = "Version was deleted."
    @version.destroy
    
    back_to_project
  end
  
  # sets the default version for a project
  def set
    @version = get_version
    return unless version_exists?(@version )
    
    # only allow project owners to set the default version
    if @version and @version.project and @version.project.owned_by?(current_or_anon_user)
      @version.update_attribute(:updated_at, Time.now)
      flash[:success] = "Default Project Download has been changed."
      @project.set_default_version(@version)
    else
      flash[:error] = "Version no longer exists."      
    end
    
    back_to_project
  end
  
  protected
  def get_version
    @current_version ||= Version.find_by_id(params[:id])
  end
  
  def version_exists?(version)
    unless version
      flash[:error] = "Version no longer exists."
      back_to_project
      return false      
    end
    return true
  end
  
  def verify_user_access(version)
    unless version.owned_by?(current_or_anon_user)
      flash[:error] = "You don't have access to this"
      back_to_project
      return false
    end
    
    return true
  end
  
end
