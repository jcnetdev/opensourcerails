class Project < ActiveRecord::Base
  validates_presence_of :title, :on => :create, :message => "can't be blank"

  belongs_to :owner, :class_name => "User"
  belongs_to :author, :class_name => "User"

  has_many :comments, :order => "created_at", :dependent => :nullify
  has_many :screenshots, :order => "created_at DESC", :dependent => :delete_all

  has_many :versions, :order => "updated_at DESC", :dependent => :delete_all
  has_many :hosted_instances, :order => "updated_at DESC", :dependent => :delete_all
  has_many :instructions, :order => "updated_at DESC", :dependent => :delete_all
  
  has_many :bookmarks, :dependent => :destroy
  has_many :activities, :order => "updated_at DESC", :dependent => :delete_all
  
  named_scope :upcoming, :conditions => {:in_gallery => false, :is_submitted => true}, :order => "last_changed DESC"
  named_scope :gallery, :conditions => {:in_gallery => true, :is_submitted => true}, :order => "promoted_at DESC"
  named_scope :top, :limit => AppConfig.project_list_max, :order => "last_changed DESC"
  
  validates_uniqueness_of :title, :on => :create, :message => "must be unique"

  attr_accessible :title, :description, :author_name, :author_contact, :requirements,
                  :homepage_url, :source_url, :license, :short_description, :tag_list

  # checkbox used to auto assign author from current_user
  attr_accessor :is_creator
  
  before_save :prepend_urls
  before_save :truncate_short_description
  before_create :mark_changed

  # allow projects to be rated
  acts_as_rated
  
  # used to temporarily store user rating
  attr_accessor :user_rating
  
  # allow project to be tagged
  acts_as_taggable
  
  # Wire up Activities
  after_save do |record|
    if record.is_submitted?
      Activity.create_from(record)
    end
  end

  # round the average rating
  def rating_in_halves
    if self.rating_average
      self.rating_average.round
    else
      0
    end
  end
  
  def to_param
    permalink = title||""
    "#{id}-#{permalink.gsub(/[^a-z0-9]+/i, '-')}"
  end
  
  # sets project screenshot information
  def set_default_screenshot(screen)
    return unless screen
    
    self.thumb_url = screen.screenshot.url(:thumb)
    self.preview_url = screen.screenshot.url(:medium)
    self.screenshot_url = screen.screenshot.url
    self.save
  end

  # sets project information to a specific download version
  def set_default_version(version)
    return unless version
    
    self.download_url = version.download.url
    self.save
  end

  # checks if a given user owns this project
  def owned_by?(user)
    return false unless user.is_a? User
    
    # allow admins and project owners to edit
    user.admin? or self.owner == user
  end
  
  # Add one to the download count
  def increment_downloads
    self.downloads = self.downloads+1
    self.save
  end
  
  def next
    # TODO: find the previous project (via promoted_at col)
    self
  end
  
  def previous
    # TODO: find the previous project (via promoted_at col)
    self
  end
    
  # Search projects with a given search string
  def self.search(search_term, options = {})
    
    # build up find options
    find_options = {}
    find_options[:order] = "created_at DESC"
    
    # set find conditions (we'll need to convert this to a proper search system like sphinx or solr)
    find_options[:conditions] = ["is_submitted=? AND (title LIKE ? OR short_description LIKE ? OR description LIKE ?)", true, "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"]
    
    # allow overrides 
    find_options.merge!(options)
    
    # only paginate if page is specified
    if find_options.has_key?(:page)
      return paginate(find_options)
    else
      find_options.delete(:page)
      find_options.delete(:per_page)
      return find(:all, find_options)
    end
  end
  
  def self.gallery_tags
    tag_counts(:conditions => {:in_gallery => true, :is_submitted => true}, :order => "name")
  end
  
  # Top Downloaded
  def self.top_downloaded(limit = 5)
    find(:all, :limit => limit, :conditions => {:is_submitted => true}, :order => "downloads DESC")
  end

  # Top Bookmarked
  def self.top_bookmarked(limit = 5)
    find(:all, :limit => limit, :conditions => {:is_submitted => true}, :order => "bookmarks_count DESC")    
  end
  
  # Top Rated
  def self.top_rated(limit = 5)
    find(:all, :limit => limit, :conditions => {:is_submitted => true}, :order => "rating_total DESC")    
  end

  # mark the application as updated
  def mark_changed
    self.last_changed = Time.now
  end
  
  def mark_changed!
    mark_changed
    self.save!
  end
  
  # Resynchronize counter caches for project
  def refresh_counts!
    
    counters = {}
    
    counters[:bookmarks_count] = self.bookmarks(:refresh).length
    counters[:comments_count] = self.comments(:refresh).length
    counters[:hosted_instances_count] = self.hosted_instances(:refresh).length
    counters[:instructions_count] = self.instructions(:refresh).length
    counters[:screenshots_count] = self.screenshots(:refresh).length
    counters[:versions_count] = self.versions(:refresh).length
    
    # how the fuck am I supposed to set the damn counters?
    # ActiveRecord::Base::update_counters is bullshit, it only does increment/decrement

    # so whatever, I'm doing it manually
    set_values = ActiveRecord::Base.send :sanitize_sql_for_assignment, counters
    update_sql = "UPDATE projects SET #{set_values} WHERE id=#{self.id}"
    Project.connection.execute(update_sql)
  end
  
  # Resynchronize counter caches for all projects
  def self.refresh_all_counts
    find(:all).each do |p|
      p.refresh_counts!
    end
  end  
  
  def meta_keywords
    self.tag_list.join(" ")
  end
    
  protected
  # check the urls for a valid prefix, and if append http:// if necessary
  def prepend_urls    
    unless check_url(self.homepage_url)
      self.homepage_url = "http://#{self.homepage_url}"
    end
    unless check_url(self.source_url)
      self.source_url = "http://#{self.source_url}"
    end
    unless check_url(self.author_contact)
      self.author_contact = "http://#{self.author_contact}"
    end
  end
  
  def check_url(url)
    url.blank? ||
    url =~ /http\:\/\// || 
    url =~ /https\:\/\// || 
    url =~ /mailto\:/ 
  end
  
  # dont let short descriptions be longer than 64 characters
  def truncate_short_description
    if self.short_description
      self.short_description = self.short_description[0..64]
    end
  end
  
end
