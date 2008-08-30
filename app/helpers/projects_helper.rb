module ProjectsHelper

  def gallery_url
    if session[:page].blank?
      root_url
    else
      root_url :page => session[:page]
    end
  end
  
  def activity_display(activity, options = {})
    partial "activities/activity", options.merge(:activity => activity)
  end
  
  def activity_target_link(activity)    
    if activity.project_id and activity.target_id
      target_link = nil
      
      # yeeeaah, we have to do this the long way in order to save N+1 database calls
      if activity.target_type == "Comment"
        target_link = project_comment_url(:project_id => activity.project_id, :id => activity.target_id)
      elsif activity.target_type == "HostedInstance"
        target_link = project_hosted_instance_url(:project_id => activity.project_id, :id => activity.target_id)
      elsif activity.target_type == "Version"
        target_link = project_version_url(:project_id => activity.project_id, :id => activity.target_id)
      elsif activity.target_type == "Screenshot"
        target_link = project_screenshot_url(:project_id => activity.project_id, :id => activity.target_id)
      end
      
      link_to_if target_link, activity.target_name, target_link
    else
      return activity.target_name
    end
    
  end
  
  def bookmark_control(project)
    
    haml_tag :span, :class => "bookmark-control" do
      if current_or_anon_user.bookmarked?(project)
        puts link_to_image("favorite.png", project_bookmark_url(project), :method => :delete, :title => "Click to Remove Bookmark")
        puts link_to("Unbookmark it...", project_bookmark_url(project), :method => :delete)
      else
        puts link_to_image("favorite-off.png", project_bookmark_url(project), :method => :post, :title => "Click to Add Bookmark")
        puts link_to("Bookmark It", project_bookmark_url(project), :method => :post)
      end
      puts " | "
      puts "Bookmarked by "+pluralize(project.bookmarks.size, "person")
    end    
  end
  
  # Render a mini bookmark button with count
  def bookmark_mini(project)
    haml_tag :span, :class => "bookmark-mini" do
      # Add Bookmark Button
      bookmark_count = pluralize(project.bookmarks.size, "person")+" bookmarked this application"
      if current_or_anon_user.bookmarked?(project)
        puts link_to_image("favorite-mini.png", project_bookmark_url(project), :method => :delete, :title => bookmark_count, :class => "bookmark-button remove")
      else
        puts link_to_image("favorite-off-mini.png", project_bookmark_url(project), :method => :post, :title => bookmark_count, :class => "bookmark-button add")
      end
    end
  end
  
  def rating_explain(project)
    "Rated by #{pluralize(project.rated_count, 'person')} with an average of "+sprintf("%.01f.", project.rating_average || 0)
  end
  
  def voting(project, detailed = false)
    
    haml_tag :div, :class => "votes" do
      if detailed
        bookmark_control(project)
      else        
        # Add Download Button
        unless project.download_url.blank?
          puts content_tag(:span, link_to_image("download-mini.png", download_project_url(project), :title => "Download Latest Version"))
        end        
        
        # Render the mini bookmark buttons
        bookmark_mini(project)
        
        # Add Comments Button
        puts content_tag(:span, link_to_image("comments2-mini.png", project_comments_url(project), :title => pluralize(project.comments.size, "comment")))
      end
    end
  end
  
  def check_empty(collection, name = nil, &block)
    if collection.nil? or collection.empty?
      inner_html = capture_haml(&block) if block_given?
      
      haml_tag(:p, "There are no #{name} currently associated with this application. #{inner_html}", :class => "empty")
      
      
    end
  end
  
  def search_or_tag_title
    if @tag
      label = pluralize(@tag.taggings.size, 'project')
      title = "#{label} tagged with \"<strong>#{@tag.name}</strong>\""
    elsif @search_term and @projects.respond_to?(:total_entries)
      label = pluralize(@projects.total_entries, "search result")
      title = "Found #{label} for \"<strong>#{@search_term}</strong>\""
    end
    
    # format the title with an h3
    unless title.blank?
      return content_tag(:h3) do 
        link_to("Clear Results", {:q => ""}) + 
        title
      end
    end
  end
  
  # Display an approve button for a project (if permissions allow)
  def approve_button(project)
    
    if logged_in? and admin?
    
      haml_tag :div, :class => "actions text-center" do
        puts br
        puts link_to(image_tag("big-approve-button.png"),
                        approve_project_url(@project), 
                        :method => :put,
                        :confirm => "This will promote the application to the gallery.")
      end
    end
  end

  # Display an approve button for a project (if permissions allow)
  def delete_button(project)
    if admin?
      haml_tag :div, :class => "actions text-center" do
        puts br
        puts link_to("Delete Project",
                        project_url(@project), 
                        :method => :delete,
                        :confirm => "This delete this project and all related information. There is no UNDO. Continue?")
      end
    end
  end


  def deploy_now(project)
    content_tag(:div, :class => "deploy-now") do
      link_to "Deploy your <strong>own</strong> version of<br />#{project.title.upcase} to mor.ph", "#"
    end
  end


  # Allow showing an article IF:
  # - the current user is a spammer. let the spammers eat their f*$&ing spam
  # - OR - 
  # - the current item ISNT being posted by a spammer
  def spam_shield?(project_item)
    return true unless project_item and project_item.owner

    if current_or_anon_user.spammer? or !project_item.owner.spammer?
      return true
    else
      return false
    end
  end
  
end
