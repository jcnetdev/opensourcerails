class Bookmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :project, :counter_cache => true
end
