atom_feed do |feed|
  feed.title AppConfig.site_name
  
  feed.updated((@projects.first.promoted_at)) unless @projects.empty?

  @projects.each do |project|
    feed.entry(project, :published => project.promoted_at, :updated => project.promoted_at) do |entry|
      entry.title(project.title)
      entry.content(image_tag(AppConfig.site_url+project.preview_url, :style => "float:left;margin-right:10px")+simple_format(project.description)+"<br style='clear:both' />", :type => 'html')
      
      entry.author do |author|
        author.name(project.owner.to_s)
      end
    end
  end
end