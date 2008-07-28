class BlogController < ApplicationController
  def index
    @posts = Blog::Post.posts
  end
  
  def show
    @post = Blog::Post.posts.find(params[:id])
  end
end
