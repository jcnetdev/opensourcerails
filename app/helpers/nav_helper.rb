module NavHelper
  def menu_item(title, link, selected = false)
    link_to menu_tag(title), link, :class => (selected ? "select" : "")
  end
  
  def menu_tag(title)
    content_tag(:span, content_tag(:span, title, :class => "menu_right"), :class => "menu_left")
  end
end