class Base::ProjectSubpage < ApplicationController
  before_filter :get_project
    
  protected
  def back_to_project(urlhash = "")
    flash.keep
    redirect_to(project_url(@project)+urlhash)
  end
  
  def get_project
    @project ||= Project.find(params[:project_id])
  end
end
