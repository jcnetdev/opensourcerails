# Activities are of the format:
# [user_name] [action_name] [midsentence] [target_name] [endconnector] [project_name]
# user_name comes with an associated user_id
# target_name comes with an associated polymorphic association for target
# project_name comes with an associated project
# 
# SOME EXAMPLES:
# 
# Legend
# 1 => user_name
# 2 => action_name
# 3 => midsentence
# 4 => target_name
# 5 => endconnector
# 6 => project_name
# 
# examples:
# [Joe] [uploaded] [a new] [screenshot] [to] [LovdByLess]
#   1       2         3        4          5        6     
# 
# 
# examples:
# [Nick] [create] [a new] [project:] [] [LovdByLess]
#    1       2      3         4       5      6      
# 
# or maybe:
# [I] [did not have sexual relations] [with] [that woman]   []    []
#  1         2                           3         4         5     6    


class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true
  belongs_to :project  
  
  # 
  def self.latest(limit = 20)
    find(:all, :limit => limit, :order => "happened_at DESC")
  end

  # Find the latest activities for a given target (user, project, or anything else)
  def self.latest_for(target, limit = 20)
    # build conditions
    conditions = {}
    if target.is_a? User
      conditions = {:user_id => target.id}
    elsif target.is_a? Project
      conditions = {:project_id => target.id}
    else
      conditions = {:target_id => target.id, :target_type => target.class.to_s}
    end
      
    # execute search
    return find(:all, :conditions => conditions, :limit => limit, :order => "happened_at DESC")
  end  
  
  # call the associated create method
  def self.create_from(model)
    
    # skip activity records for spam
    if model.respond_to? :owner
      if model.owner and model.owner.spammer?
        return true
      end
    end
    
    # initialize the model states
    # its either new, updated, or deleted
    is_new, is_updated, is_deleted = false, false, false
    is_new = (model.created_at == model.updated_at)
    is_updated = !is_new

    # check if its deleted
    if model.frozen?
      is_new, is_updated, is_deleted = false, false, true
    end
    
    # find and call the associated activity creator
    model_name = model.class.to_s.tableize
    method_name = :"activity_for_#{model_name}"
    if respond_to? method_name
      send method_name, model, is_new, is_updated, is_deleted
    end
  end
  
  protected
  # Someone created/updated a project
  # create: [Joe] [created] [a new application:] [] [] [LovdByLess]
  # update: [Joe] [updated] [the application details of] [] [] [LovdByLess]
  # destroy: [Joe] [deleted] [the application:] [] [] [LovdByLess]
  def self.activity_for_projects(project, is_new, is_updated, is_deleted) 
    a = Activity.new
    a.user_name = project.owner.to_s
    a.user_id = project.owner_id

    a.action_name = "created" if is_new
    a.action_name = "updated" if is_updated
    a.action_name = "deleted" if is_deleted
    
    a.midsentence = "a new application:" if is_new
    a.midsentence = "the application details of" if is_updated
    a.midsentence = "the application:" if is_deleted
    
    a.project_name = project.title
    a.project_id = project.id
    a.happened_at = project.created_at

    a.source_model = "project"
    a.source_action = get_source_action(is_new, is_updated, is_deleted)
    a.save
  end
  
  # Someone added a new comment
  # create: [Joe] [wrote] [a new] [comment] [on] [LovdByLess]
  # update: [Joe] [made an update] [to his/her] [comment] [on] [LovdByLess]
  # deleted: [Joe] [deleted] [his/her] [comment] [on] [LovdByLess]
  def self.activity_for_comments(comment, is_new, is_updated, is_deleted) 
    # no activity records needed for update
    return if is_updated
    
    
    a = Activity.new
    a.user_name = comment.author_name
    a.user_id = comment.owner_id

    a.action_name = "wrote" if is_new
    a.action_name = "made an update" if is_updated
    a.action_name = "deleted" if is_deleted
    
    a.midsentence = "a new" if is_new
    a.midsentence = "to his/her" if is_updated
    a.midsentence = "his/her" if is_deleted
    
    a.target_name = "comment"
    a.target = comment unless is_deleted
    
    a.endconnector = "on"
    a.project_name = comment.project.title
    a.project_id = comment.project_id
    
    a.happened_at = comment.created_at if is_new
    a.happened_at = comment.updated_at if is_updated
    a.happened_at = Time.now if is_deleted

    a.source_model = "comment"
    a.source_action = get_source_action(is_new, is_updated, is_deleted)
    a.save
  end
  
  # Someone added a new screenshot
  # created: [Joe] [uploaded] [a new] [screenshot] [for] [LovdByLess]
  # batch create: [Joe] [uploaded] [8 new] [screenshots] [for] [LovdByLess]
  # deleted: [Joe] [deleted] [his/her] [screenshot] [for] [LovdByLess]
  # batch delete: [Joe] [deleted] [5] [screenshots] [from] [LovdByLess]
  def self.activity_for_screenshots(screenshot, is_new, is_updated, is_deleted) 

    # no updates allowed to screenshots
    return if is_updated
    return unless screenshot.project
    
    # see if we have a previous activity
    previous = Activity.find(:first, :conditions => {
                                        :user_id => screenshot.owner_id, 
                                        :project_id => screenshot.project_id, 
                                        :source_model => "screenshot", 
                                        :source_action => get_source_action(is_new, is_updated, is_deleted)
                                      });
    
    # if so and if its recent, then update it instead of creating a new one
    if previous and previous.happened_at > 2.hours.ago
      # convert the midsentence to a number
      old_count = previous.midsentence.to_i
      
      # if its zero, that means we are moving from singular to plural
      old_count = 1 if old_count == 0
      
      # increment it by one
      new_count = old_count.next

      previous.midsentence = "#{new_count} new" if is_new
      previous.midsentence = "#{new_count}" if is_deleted      
      previous.target_name = "screenshots"


      previous.happened_at = screenshot.created_at if is_new
      previous.happened_at = Time.now if is_deleted
      
      previous.save
      
    else
      a = Activity.new
      a.user_name = screenshot.owner.to_s
      a.user_id = screenshot.owner_id

      a.action_name = "uploaded" if is_new
      a.action_name = "deleted" if is_deleted

      a.midsentence = "a new" if is_new
      a.midsentence = "a" if is_deleted

      a.target_name = "screenshot"
      a.target = screenshot unless is_deleted

      a.endconnector = "for"
      a.endconnector = "from" if is_deleted

      a.project_name = screenshot.project.title
      a.project_id = screenshot.project_id

      a.happened_at = screenshot.created_at if is_new
      a.happened_at = Time.now if is_deleted

      a.source_model = "screenshot"
      a.source_action = get_source_action(is_new, is_updated, is_deleted)
      a.save
    end
    
  end
  
  # Someone added a new version
  # created: [Joe] [uploaded] [a new] [version] [of] [LovdByLess]
  # deleted: [Joe] [deleted] [an old] [version] [of] [LovdByLess]
  def self.activity_for_versions(version, is_new, is_updated, is_deleted) 
    
    # no updated allowed to versions
    return if is_updated
    
    a = Activity.new
    a.user_name = version.owner.to_s
    a.user_id = version.owner_id

    a.action_name = "uploaded" if is_new
    a.action_name = "deleted" if is_deleted
    
    a.midsentence = "a new" if is_new
    a.midsentence = "an old" if is_deleted
    
    a.target_name = "version"
    a.target = version unless is_deleted
    
    a.endconnector = "of"
    a.project_name = version.project.title
    a.project_id = version.project_id
    
    a.happened_at = version.created_at if is_new
    a.happened_at = Time.now if is_deleted
    
    a.source_model = "version"
    a.source_action = get_source_action(is_new, is_updated, is_deleted)
    a.save
    
  end
  
  # Someone added a new hosted instance
  # created: [Joe] [added] [a new] [link to a hosted version] [of] [LovdByLess]
  # created: [Joe] [deleted] [an old] [link] [for] [LovdByLess]
  def self.activity_for_hosted_instances(hosted_instance, is_new, is_updated, is_deleted) 

    # no updated allowed to hosted_instances
    return if is_updated

    a = Activity.new
    a.user_name = hosted_instance.owner.to_s
    a.user_id = hosted_instance.owner_id

    a.action_name = "added" if is_new
    a.action_name = "deleted" if is_deleted

    a.midsentence = "a new" if is_new
    a.midsentence = "an old" if is_deleted

    a.target_name = "link to a hosted version" if is_new
    a.target_name = "link" if is_deleted
    a.target = hosted_instance unless is_deleted
    
    a.endconnector = "of" if is_new
    a.endconnector = "for" if is_deleted

    a.project_name = hosted_instance.project.title
    a.project_id = hosted_instance.project_id

    a.happened_at = hosted_instance.created_at if is_new
    a.happened_at = Time.now if is_deleted

    a.source_model = "hosted_instance"
    a.source_action = get_source_action(is_new, is_updated, is_deleted)
    a.save
  end  
  
  # get the action string for a given source
  def self.get_source_action(is_new, is_updated, is_deleted)
    return "create" if is_new
    return "update" if is_updated
    return "delete" if is_deleted
    return ""
  end
  
end
