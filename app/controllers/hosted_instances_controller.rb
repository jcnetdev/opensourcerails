class HostedInstancesController < Base::ProjectSubpage  
  def index
    back_to_project
  end
  
  def new
    back_to_project
  end
  
  def create    
    unless check_spam(params[:hosted_instance][:antispam])
      flash[:error] = "You're either a spammer or bad at math. Either way... no link for you!"
      return redirect_to @project
    end
    
    @hosted_instance = @project.hosted_instances.build(params[:hosted_instance])
    @hosted_instance.owner = current_or_anon_user

    if @hosted_instance.save
      @project.mark_changed! unless current_or_anon_user.spammer?
      flash[:success] = "New Application Link was created."
      redirect_to @project
    else
      flash[:error] = "Unable to Save Link."
      redirect_to project_url(@project)+"#hosted_instances_add"
    end
  end
  
  def show
    @hosted_instance = get_hosted_instance
    return unless hosted_instance_exists?(@hosted_instance)
    
    redirect_to @hosted_instance.url
  end
  
  def edit
    @hosted_instance = get_hosted_instance
    return unless hosted_instance_exists?(@hosted_instance)
    return unless verify_user_access(@hosted_instance)
  end
  
  def update
    @hosted_instance = get_hosted_instance
    return unless hosted_instance_exists?(@hosted_instance)
    return unless verify_user_access(@hosted_instance)
    
    if @hosted_instance.update_attributes(params[:hosted_instance])
      flash[:notice] = "Hosted Instance Updated"
      back_to_project
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @hosted_instance = get_hosted_instance
    return unless hosted_instance_exists?(@hosted_instance)
    return unless verify_user_access(@hosted_instance)
    
    if @hosted_instance
      flash[:notice] = "Link was deleted."
      @hosted_instance.destroy
    else
      flash[:error] = "Unable to find hosted_instance to delete."
    end

    redirect_to @project
  end
  
  protected
  def get_hosted_instance
    @current_hosted_instance ||= HostedInstance.find_by_id(params[:id])
  end
  
  def hosted_instance_exists?(hosted_instance)
    unless hosted_instance
      flash[:error] = "Hosted Instance no longer exists."
      back_to_project
      return false      
    end
    return true
  end  
  
  def verify_user_access(hosted_instance)
    unless hosted_instance.owned_by?(current_or_anon_user)
      flash[:error] = "You don't have access to this"
      back_to_project
      return false
    end
    
    return true
  end
  
end


