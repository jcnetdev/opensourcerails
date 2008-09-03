class ProjectsController < ApplicationController
  def index  
    build_gallery(gallery_projects)
    @upcoming = Project.upcoming(:limit => AppConfig.project_list_max)
    respond_to do |format|
      format.html
      format.ajax do
        render :partial => "projects/parts/grid.html.haml", :locals => {:projects => @projects}, :layout => false
      end
      format.atom
    end
  end
  
  def upcoming
    @active_tab = :upcoming
    
    build_gallery(upcoming_projects)    
    respond_to do |format|
      format.html do
        @grid_title = "Upcoming Projects"
        @grid_rss = formatted_upcoming_projects_url(:atom)
        @hide_upcoming = true
        render :action => "index"
      end
      format.ajax do
        render :partial => "projects/parts/grid.html.haml", :locals => {:projects => @projects}, :layout => false
      end
      format.atom
    end
  end
  
  def feed
    @projects = Project.gallery.top
    respond_to do |format|
      format.atom do
        render :action => "index.atom.builder"
      end
    end
  end
  
  def new
    flash.keep
    redirect_to root_url
  end  
      
  def create
    @project = Project.new(params[:project])
    @project.owner_id = current_or_anon_user.id
    if params[:project] and params[:project][:is_creator] == "1"
      @project.author_id = current_or_anon_user.id 
      @project.author_name = current_or_anon_user.to_s
    end

    if @project.save      
      current_or_anon_user.add_bookmark(@project)

      session[:newproj] = @project.id

      flash[:success] = "Project has been created but not submitted. Customize it now with screenshots, files, and links before submitting it to the gallery."
      redirect_to @project
    else
      if @project.title.blank?
        flash[:error] = "Please give the application a name."
      else
        flash[:error] = "Application name is already taken."
      end
      
      redirect_to :back
    end
  end
  
  def show
    @project = Project.find_by_id(params[:id], :include => :comments)
    unless @project
      flash[:error] = "Unable to find project with the id: #{params[:id]}"
      redirect_to root_url
      return false
    end 
    
    @latest_activities = Activity.latest_for(@project)
    # verify that the project is submitted or that the currnet person is at least the owner
    unless @project.is_submitted? or @project.owned_by?(current_or_anon_user)
      flash[:error] = "That project is not yet accessible or your session may have expired."
      redirect_to root_url
    end
  end
  
  def edit
    @project = get_project
    return unless verify_owner(@project)
    
    respond_to do |format|
      format.ajax do
        render :partial => "projects/form.html.haml", :layout => false, :locals => {:ajax => true}
      end
      format.html
    end
  end
  
  def update
    @project = get_project
    return unless verify_owner(@project)

    @project.update_attributes(params[:project])
    @project.mark_changed!
    flash[:success] = %("#{@project.title}" has been updated. )
    
    respond_to do |format|
      format.ajax do
        render :partial => "projects/parts/ajax_result.html.haml", :locals => {:message => flash[:success]}
        flash.discard
      end
      format.html do
        redirect_to @project
      end
    end
  end
  
  def destroy
    @project = get_project
    return unless verify_owner(@project)

    @project.destroy
    flash[:notice] = %(Application "#{@project.title}" has been deleted.)    
    redirect_to root_url
  end  
  
  # Mark a project as submitted
  def submit
    @project = get_project

    if @project.owned_by?(current_or_anon_user)
      @project.update_attribute(:is_submitted, true)
      @project.mark_changed!
      flash[:success] = %(Application "#{@project.title}" has been submitted. It will be shown in the "Upcoming" list until it's approved by an Admin. Adding additional screenshots and links will improve its chances of being accepted into the gallery.)
    else
      flash[:error] = "You no longer have access to this application. Your session may have expired."
    end
    
    redirect_to @project
  end
    
  # Mark a project as approved
  def approve
   @project = get_project
    if logged_in? and current_user.admin?
      @project.in_gallery = true
      @project.is_submitted = true
      @project.promoted_at = Time.now
      @project.mark_changed
      @project.save!
      flash[:success] = %(Application "#{@project.title}" has been promoted. It is now in the gallery.)
    else
      flash[:error] = "Sorry, only admins are allowed to promote an application."
    end

    redirect_to root_url
  end
  
  # Rate a project
  def rate
    @project = get_project
    
    # add rating for user
    new_rating = params["rating"].to_i
    if new_rating.between?(1, 5)
      @project.rate new_rating, current_or_anon_user
    end
    
    respond_to do |format|
      format.html do
        redirect_to @project
      end
      format.ajax do 
        render :text => "", :layout => false
      end
    end
  end
  
  # Forward to a projects download url
  def download
    @project = get_project
    @project.increment_downloads
    redirect_to @project.download_url
  end  
  
  # Ajax Update to show details
  def details
    @project = get_project
    
    respond_to do |format|
      format.html do
        flash.keep
        redirect_to @project
      end
      format.ajax do
        render :partial => "projects/parts/about_project.html.haml", :locals => {:project => @project, :hidden => true}, :layout => false
      end
    end
    
  end
  
  # Ajax Update for Project Bookmarks
  def bookmarks
    @my_projects = current_or_anon_user.projects
    
    respond_to do |format|
      format.html do
        redirect_to root_url
      end
      format.ajax do
        render :partial => "bookmarks/bookmark_list.html.haml", :layout => false, :locals => {:projects => @my_projects}        
      end
    end    
  end
  
  # finds the next sequential project and redirect to it
  def next
    @project = get_project

    # todo: find real one
    redirect_to @project.next
  end
  
  # finds the previous sequential project and redirect to it
  def previous
    @project = get_project

    redirect_to @project.previous
  end
  
  protected
  def build_gallery(projects)
    @projects = projects
    @my_projects = current_or_anon_user.projects
    
    @latest_activities = Activity.latest
    
    @top_downloaded = Project.top_downloaded
    @top_bookmarked = Project.top_bookmarked
    
    if throttled?
      @tags = []
    else
      @tags = Project.gallery_tags
    end  
    
    if params[:q].blank? and params[:tag].blank?
      session[:page] = params[:page]
    end
  end
  
  # retrieves the current project from params[:id]
  def get_project
    @current_project ||= Project.find(params[:id])
  end
  
  # finds the current tag being queried on
  def get_tag
    @current_tag ||= Tag.find_by_name(params[:tag])
  end
  
  # find the projects to display based on the querystring
  def gallery_projects
    # try to find an associated tag
    @tag = get_tag  
    @search_term = params[:q].strip unless params[:q].blank?
    
    if @tag
      @projects = @tag.taggings.map{|t| t.taggable if t.taggable.is_a? Project}
    elsif @search_term
      @projects = Project.search(@search_term, :page => params[:page], :per_page => AppConfig.projects_per_page)
    else
      @projects = Project.gallery.paginate(:page => params[:page], :per_page => AppConfig.projects_per_page)
    end
  end
    
  # list the upcoming projects
  def upcoming_projects
    @projects = Project.upcoming.paginate(:page => params[:page], :per_page => AppConfig.projects_per_page)
  end

  # verify that the current user owns a project
  def verify_owner(project)
    if project.owned_by?(current_or_anon_user)
      return true
    else
      
      # render an output
      respond_to do |format|        
        flash[:error] = "You don't have access to edit this application."
        format.ajax do
          render :text => flash[:error], :layout => false
          flash.discard
        end
        format.html do
          redirect_to project
        end
      end
      return false
    end
  end
end
