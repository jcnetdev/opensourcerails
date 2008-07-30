module CommentsHelper  
  # display comment edit/delete if applicable
  def comment_actions(comment)
    if comment.owned_by?(current_or_anon_user)
      link_actions = [link_to("Edit Comment", edit_project_comment_url(@project, comment)), 
                      link_to("Delete Comment", project_comment_url(@project, comment), :method => :delete, :confirm => "Are you sure you want to delete this?")]

      if admin? and comment.owner
        link_actions << link_to("Spam!", spammer_user_url(comment.owner), :method => :put, :confirm => "Are you sure you want to mark this person as a spammer?")
      end
      
      content_tag(:div, link_actions.join(" | "), :class => "actions")
    end
  end
end
