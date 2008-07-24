module TaggingHelper
  def display_tag(tag)
    @tags ||= []

    link_to_if(tag.name != @tag, tag.name, projects_url(:tag => tag.name)) + ((@tags.last != tag) ? "," : "")
  end
  
  def project_tags(project)
    project.tag_list.map{|tag| link_to(tag.capitalize, projects_url(:tag => tag), :rel => "tag")}.join(", ")
  end
end