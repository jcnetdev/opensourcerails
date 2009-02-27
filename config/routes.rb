ActionController::Routing::Routes.draw do |map|
  
  map.open_id_complete 'sessions', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.resource :session
  map.resources :users, :member => {:activate => :get, :spammer => :put, :edit_password => :get}, :collection => {:reset_password => :any}
    
  map.resources :projects, 
                  :member => {
                    :submit => :put, 
                    :approve => :put, 
                    :details => :get, 
                    :rate => :post,
                    :download => :get
                  },
                  :collection => {
                    :upcoming => :get,
                    :activity => :get
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

  # email campaign routes
  map.email_unsubscribed "/unsubscribed", :controller => "pages", :action => "unsubscribed"
  map.email_subscribe "/subscribe", :controller => "pages", :action => "subscribe"

  map.feed "/feed", :controller => "projects", :action => "feed", :format => "atom"
  map.connect "/feed.:format", :controller => "projects", :action => "feed"
    
  map.forgot_password "/forgot_password", :controller => "users", :action => "forgot_password"
    
  # set the root to project index
  map.root :controller => "projects"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
