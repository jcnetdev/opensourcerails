class CommentsController < Base::ProjectSubpage      

  def index
    back_to_project("#comments")
  end
  
  def new
    back_to_project("#new-comment")
  end
  
  def create
    @user = current_or_anon_user

    # setup comment
    @comment = @project.comments.build(params[:comment])
    @comment.owner = @user
    
    if @comment.valid?
    
      unless check_spam(params[:comment][:antispam])
        @project.comments(true)
        flash[:error] = "You're either a spammer or bad at math. Either way... no link for you!"
        render :template => "projects/show"
        return
      end
      
      @comment.save
      @user.update_from_comment(@comment)
      flash[:success] = "Comment has been added."
      redirect_to project_comment_url(@project, @comment)
    else
      @project.comments(true)
      render :template => "projects/show"
    end
  end
  
  def show
    @comment = get_comment

    if @comment
      back_to_project("#comment-#{@comment.id}")
    else
      flash[:notice] = "That comment no longer exists."
      back_to_project
    end
  end
    
  def edit
    @comment = get_comment
    return unless verify_comment_owner
  end
  
  def update
    @comment = get_comment
    return unless verify_comment_owner

    if @comment.update_attributes(params[:comment])
      flash[:success] = "Comment has been updated."
      redirect_to project_comment_url(@project, @comment)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @comment = get_comment
    return unless verify_comment_owner
    
    if @comment.destroy
      flash[:notice] = "Comment has been deleted."
      redirect_to project_comments_url(@project)
    else
      flash[:error] = "Unable to delete comment."
      redirect_to project_comments_url(@project)
    end
  end
  
  protected
  # retrieve a specific comment by id
  def get_comment
    @current_comment ||= @project.comments.find(params[:id])
  end
  
  # verify a person has access to update a comment
  def verify_comment_owner
    comment = get_comment
    unless comment.owned_by?(current_or_anon_user)
      redirect_to(comment.project || projects_url)
      return false
    end
    
    return true    
  end  
end
