module TagHelper
  def display_tag(tag)
    @tags ||= []

    link_to_if(tag.name != @tag, tag.name, projects_url(:tag => tag.name)) + ((@tags.last != tag) ? "," : "")
  end

end