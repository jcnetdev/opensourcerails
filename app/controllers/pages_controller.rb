class PagesController < ApplicationController

  def about
  end
  
  def blog
    if AppConfig.blog_url
      redirect_to AppConfig.blog_url
    else
      flash[:notice] = "Blog coming soon..."
      redirect_to root_url
    end
  end
end
