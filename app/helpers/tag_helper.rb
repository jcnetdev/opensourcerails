module TagHelper
#   def br
#     "<br />"
#   end
# 
#   def hr
#     "<hr />"
#   end
# 
#   def space
#     "<hr class='space' />"
#   end
# 
#   def anchor(anchor_name)
#     "<a name='#{anchor_name}'></a>"
#   end
# 
#   def button(text, options = {})
#     submit_tag(text, options)
#   end
# 
#   def clear_tag(tag, direction = nil)
#     "<#{tag} class=\"clear#{direction}\"></#{tag}>"
#   end
# 
#   def clear(direction = nil)
#     clear_tag(:div, direction)
#   end
#   
#   def lorem
#     "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
#   end
#   
#   def hidden(is_hidden = true)
#     if is_hidden
#       {:style => "display:none"}
#     else
#       {}
#     end
#   end
#   
#   def hidden_if(is_hidden)
#     hidden(is_hidden)
#   end
#   
#   def hidden_unless(is_hidden)
#     hidden(!is_hidden)
#   end
#   
#   def clearbit_icon(icon, color, options = {})
#     image_tag "clearbits/#{icon}.gif", {:class => "clearbits #{color}", :alt => icon}.merge(options)
#   end
#   
#   def delete_link(*args)
#     options = {:method => :delete, :confirm => "Are you sure you want to delete this?"}.merge(args.extract_options!)
#     args << options
#     link_to *args
#   end
#   
#   def link_to_block(*args, &block)
#     content = capture_haml(&block)
#     return link_to(content, *args)
#   end
#   
#   def link_to_image(img_url, link_url, options={})
#     
#     link = []
#     label = options.delete(:label)
#     
#     link << link_to(image_tag(img_url), link_url, options)
#     link << link_to(label, link_url, options) if label
#     
#     link.join(" ");
#   end
#   
#   # pixel spacing helper
#   def pixel(options = {})
#     image_tag "pixel.png", options
#   end
# 
end