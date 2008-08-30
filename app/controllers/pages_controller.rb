class PagesController < ApplicationController

  def about
    if request.post?
      @tell_friend = TellFriend.new(params[:tell_friend])
      @tell_friend.valid?
      if button_pressed?(:send)
        if @tell_friend.send_msg(current_or_anon_user)
          flash[:success] = "Sent Message. Thanks for helping to promote #{AppConfig.site_name}!"
          redirect_to about_url
        end
      elsif button_pressed?(:preview)
        @preview = true
      end
    else
      @tell_friend = TellFriend.new(:from => current_or_anon_user.email)
    end
  end
  
  def blog
    if AppConfig.blog_url
      redirect_to AppConfig.blog_url
    else
      flash[:notice] = "Blog coming soon..."
      redirect_to root_url
    end
  end
  
  protected
  def button_pressed?(id)
    !params[id].blank?
  end
end
