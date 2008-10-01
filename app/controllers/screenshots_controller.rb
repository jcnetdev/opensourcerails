class ScreenshotsController < Base::ProjectSubpage
  def show
    @screenshot = get_screenshot
    if @screenshot
      redirect_to @screenshot.screenshot.url
    else
      flash[:notice] = "That screenshot no longer exists."
      back_to_project
    end
  end
  
  def create
    # check original size of screenshots
    orig_size = @project.screenshots.size
    
    @valid_screenshots = []
    @invalid_screenshots = []
    
    params[:screenshots].each do |screenshot|
      @screenshot = @project.screenshots.build(screenshot)
      @screenshot.owner = current_or_anon_user
      if @screenshot.save
        @valid_screenshots << @screenshot
      else
        @invalid_screenshots << @screenshot
      end
    end
    
    if @valid_screenshots.size > 0
      begin
        @project.mark_changed! unless current_or_anon_user.spammer?
      rescue
        logger.error("UNABLE TO UPLOAD SCREENSHOTS")
      end
      
      if orig_size == 0
        @project.set_default_screenshot(@valid_screenshots.first)
      end
      
      flash[:success] = "Screenshots Uploaded."
      redirect_to project_url(@project)
    else
      @invalid_screenshots.each{|screenshot| set_flash(screenshot) }
      redirect_to project_url(@project)+"#screenshots_add"
    end
  end
  
  def destroy
    @screenshot = get_screenshot
    if @screenshot
      flash[:notice] = "Screenshot was deleted."
      @screenshot.destroy
    else
      flash[:error] = "Unable to find screenshot to delete."
    end
    
    redirect_to @project
  end
  
  # sets the default screenshot for a project
  def set
    @screenshot = get_screenshot    
    if @screenshot and @screenshot.owned_by?(current_or_anon_user)
      flash[:success] = "Default Application Screenshot has been updated."
      @project.set_default_screenshot(@screenshot)
    else
      flash[:error] = "Unable to set default screenshot."
    end
    
    redirect_to @project
  end
    
  # unsupported actions
  def index
    back_to_project
  end
  
  def new
    back_to_project
  end

  def edit
    back_to_project
  end
  
  protected 
  
  def get_screenshot
    @current_screenshot ||= Screenshot.find_by_id(params[:id])
  end
  
  def set_flash(screenshot)
    if screenshot.errors.on(:name)
      flash[:error] = "No File Uploaded."        
    elsif screenshot.errors.on(:content_type)
      flash[:error] = "Please upload a valid image (png, gif, or jpg)."
    elsif screenshot.errors.on(:size)
      flash[:error] = "Please limit the size to 1meg for screenshots. Bandwidth doesn't grow on trees you know!"
    else
      flash[:error] = "Sorry, the upload failed."
      logger.error("Bad Upload! #{screenshot.errors.to_yaml}")
    end
  end
  
end
