# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  # display flash_boxes (unless its already been shown)
  def flash_boxes
    unless @flash_shown
      @flash_shown = true
      partial "layouts/flash_boxes"
    else
      ""
    end
  end
  
  # returns the controller & action
  def action_path
    "#{params[:controller]}/#{params[:action]}"
  end
  
  def active_tab(set_tab = nil)
    if set_tab
      @active_tab ||= set_tab
    end
    
    return @active_tab
  end
  
  # return the css class for the current controller and action
  def body_class
    classes = ""
    classes << "container"
    classes << " "
    classes << controller.controller_name
    classes << "-"
    classes << controller.action_name
    classes << " "
    unless production? 
      classes << "debug" 
    end
    
    return classes.strip
  end
  
  def production?
    ENV["RAILS_ENV"] == "production"
  end
  
  # returns either the new_arg or the edit_arg depending on if the action is a new or edit action
  def new_or_edit(new_arg, edit_arg, other = nil)
    if is_new?
      return new_arg
    elsif is_edit?
      return edit_arg
    else
      return other
    end
  end
  
  def is_new?
    action = params[:action]
    action == "new" || action == "create"
  end
      
  def is_edit?
    action = params[:action]
    action == "edit" || action == "update"
  end
  
  def link_to_image(img_url, link_url, options={})
    
    link = []
    label = options.delete(:label)
    
    link << link_to(image_tag(img_url), link_url, options)
    link << link_to(label, link_url, options) if label
    
    link.join(" ");
  end
  
  # adds a "first" class if an index is zero
  # hook this up to the partial counter
  def is_first(index)
    if index.nonzero?
      return {}
    else
      return {:class => "first"}
    end
  rescue
    return {}
  end
  
  def right_box(css_class="", &block)
    haml_tag :div, :class => "right-box" do
      haml_tag :div, :class => "right-box-top #{css_class}" do
        haml_tag :div, :class => "right-box-end" do
          haml_tag :div, :class => "right-box-body" do
            puts capture_haml(&block)
          end
        end
      end
    end
  end
  
  def progress(img_path = nil)
    # set default progress image
    img_path ||= "progress.gif"

    content_tag :div, image_tag(img_path), :class => "progress hidden"
  end
  
  def current_year
    Time.now.strftime('%Y')
  end
  
  def paging(page_data, style = :sabros)
    return unless page_data.class == WillPaginate::Collection    
    will_paginate(page_data, :class => "pagination #{style}", :outer_window => 1, :inner_window => 1)
  end
  
  def error_messages_for(name, options = {})
    super(name, {:id => "error_explanation", :class => "error"}.merge(options))
  end
  
  def default(val, default = "")
    if val.blank?
      return default
    else
      return val
    end
  end
  
  def name_display(user)
    if current_or_anon_user == user
      return "Your"
    elsif !user.name.blank?
      return "#{user.name}'s"
    elsif !user.login.blank?
      return "#{user.login}'s"
    else
      return "User's"
    end
  end
  
  def paging?(list)
    list.is_a? WillPaginate::Collection
  end
  
  def hide_login_panel?
    @hide_login_panel
  end
  
  def hide_login_panel
    @hide_login_panel = true
  end

  def projects_rss
    AppConfig.rss_url || formatted_projects_url(:atom)
  end

  def upcoming_rss
    AppConfig.upcoming_rss_url || formatted_upcoming_projects_url(:atom)
  end

  def activity_rss
    AppConfig.upcoming_activity_url || formatted_activity_projects_url(:atom)
  end
end
