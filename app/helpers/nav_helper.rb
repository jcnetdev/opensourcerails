module NavHelper
  def menu_item(title, link, selected = false)
    link_to content_tag(:span, content_tag(:span, title, :class => "menu_right"), :class => "menu_left"), link, :class => (selected ? "select" : "")
  end
end