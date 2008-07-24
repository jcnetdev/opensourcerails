class ProjectRating < ActiveRecord::Base 
  set_table_name "ratings"
  belongs_to :project, :foreign_key => "rated_id"
end