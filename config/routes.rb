ActionController::Routing::Routes.draw do |map|
  
  map.resource :session
  map.resources :users, :member => {:activate => :get, :spammer => :put, :edit_password => :get}, :collection => {:reset_password => :any}
    
  map.resources :projects, 
                  :member => {
                    :submit => :put, 
                    :approve => :put, 
                    :details => :get, 
                    :rate => :post,
                    :download => :get
                  } do |project|    

    project.resources :comments
    project.resource :bookmark
    project.resources :versions, :member => {:set => :put}
    project.resources :screenshots, :member => {:set => :put}
    project.resources :hosted_instances, :member => {:set => :put}
  end
  
  map.search "/search", :controller => "projects", :action => "search"  
  map.bookmarks "/bookmarks", :controller => "projects", :action => "bookmarks"
  map.about "/about", :controller => "pages", :action => "about"
  map.blog "/blog", :controller => "pages", :action => "blog"

  map.feed "/feed", :controller => "projects", :action => "feed", :format => "atom"
  map.connect "/feed.:format", :controller => "projects", :action => "feed"
    
  map.forgot_password "/forgot_password", :controller => "users", :action => "forgot_password"
    
  # add actions for next/previous project
  map.next_project "/projects/:id/next", :controller => "projects", :action => "find_next"
  map.prevous_project "/projects/:id/previous", :controller => "projects", :action => "find_previous"

  # set the root to project index
  map.root :controller => "projects"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
