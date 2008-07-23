class PagesController < ApplicationController

  def about
  end
  
  def blog
    flash[:notice] = "Blog coming soon..."
    redirect_to root_url
  end
end
