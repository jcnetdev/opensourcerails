class BookmarksController < Base::ProjectSubpage
  def create
    current_or_anon_user.add_bookmark(@project)
    @project.bookmarks(true)    
    respond_to do |format|
      format.html do 
        flash[:success] = "#{@project.title} is now bookmarked."
        redirect_to @project 
      end
      format.ajax { render_bookmark_control }
    end
  end
  
  def destroy
    current_or_anon_user.remove_bookmark(@project)
    @project.bookmarks(true)
    respond_to do |format|
      format.html do 
        flash[:success] = "#{@project.title} is no longer bookmarked."
        redirect_to @project         
      end
      format.ajax { render_bookmark_control }
    end
  end
  
  protected
  def render_bookmark_control
    render :partial => "bookmark_mini.html.haml", :layout => false, :locals => {:project => @project}    
  end
end
