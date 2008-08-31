require 'digest/sha1'
class User < ActiveRecord::Base
  
  named_scope :active, :conditions => {:state => "active"}
  
  has_many :bookmarks
  has_many :projects, :through => :bookmarks, :order => "last_changed DESC"
  has_many :submitted, :class_name => "Project", :foreign_key => "owner_id"

  # additional relationships
  has_many :activities
  has_many :comments, :class_name => "Comment", :foreign_key => "owner_id"
  has_many :hosted_instances, :class_name => "HostedInstance", :foreign_key => "owner_id"
  has_many :screenshots, :class_name => "Screenshot", :foreign_key => "owner_id"
  has_many :versions, :class_name => "Version", :foreign_key => "owner_id"
  
  # find user ratings
  has_many :rated, :class_name => "ProjectRating", :foreign_key => "rater_id"
  def rated_projects
    project_list = []
    rated.all(:order => "created_at DESC", :include => [:project]).each do |r|
      p = r.project
      p.user_rating = r
      project_list << p
    end
    
    return project_list
  end
  
  named_scope :registered, :conditions => ["state = 'active' OR state = 'pending'"]
  named_scope :nil_password, :conditions => {:crypted_password => nil}
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessor :skip_email

  # basic info validations
  validates_presence_of       :login,                               :if => :signed_up?
  validates_length_of         :login, :within => 3..40,             :if => :signed_up?,               :allow_blank => true
  validates_uniqueness_of     :login, :case_sensitive => false,     :if => :signed_up?,               :allow_blank => true
  validates_format_of :login, :with => /^\w+$/i, :message => "must only contain letters and numbers", :allow_blank => true
  
  # set up email
  validates_presence_of       :email,                               :if => :email_required?
  validates_length_of         :email, :within => 3..100,            :if => :email_required?
  validates_uniqueness_of     :email, :case_sensitive => false,     :if => :email_required?
  validates_as_email_address  :email,                               :if => :email_required?
    
  # password validations
  validates_presence_of     :password,                     :if => :password_required?
  validates_presence_of     :password_confirmation,        :if => :password_required?
  validates_length_of       :password, :within => 4..40,   :if => :password_required?
  validates_confirmation_of :password,                     :if => :password_required?

  before_save               :encrypt_password

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :signup, :homepage, :name, :about

  acts_as_state_machine :initial => :anonymous
  state :anonymous
  state :pending, :enter => :do_register
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :anonymous, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => :pending, :to => :active 
  end
  
  event :suspend do
    transitions :from => [:anonymous, :pending, :active], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:anonymous, :pending, :active, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :anonymous
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    if login.to_s.include?("@")
      u = first(:conditions => {:email => login})
    else
      u = first(:conditions => {:login => login})
    end
    
    u && u.authenticated?(password) ? u : nil
  end
  
  def self.login_with(login)
    if login.valid?
      u = self.authenticate(login.login, login.password)
      if u and u.active?
        return u
      else
        if u
          login.error_message = "Please confirm your email address before logging in."
        else
          login.error_message = "Invalid username and password."
        end
        return nil
      end
    end
  end
  
  def send_forgot_password
    self.forgot_password_hash = encrypt("#{self.id}--#{Time.now}")
    self.forgot_password_expire = (AppConfig.forgot_password_expire||5).days.from_now
    if self.crypted_password.blank?
      self.password = "changeme"
      self.password_confirmation = "changeme"
    end
    
    self.save!
    
    UserMailer.deliver_send_password_reset(self)
  end
  
  def login
    if self[:login].blank?
      "anon_#{self.id}"
    else
      self[:login]
    end
  end
    
  
  # finds an email and initiate the forgot password flow
  def self.forgot_password(email)
    return false if email.blank?
    
    # find matching user
    u = User.find_by_email(email)
    return false unless u
    
    u.send_forgot_password
    return true
  end


  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def to_s
    return self.login unless self[:login].blank?
    return self.name unless self.name.blank?    
    return "Anonymous"
  end
  
  def to_param
    return self.login
  end
  
  def update_from_comment(comment)
    unless self.signed_up?
      self.name = comment.author_name if self.name.blank?
      self.save
    end
  end
    
  # bookmark a new project for user
  def add_bookmark(project)
    unless bookmarked?(project)
      self.projects << project
      self.update_attribute(:bookmark_blob, "#{self.bookmark_blob}"+"|#{project.id}|")
    end
  end
  
  # remove a project from user's bookmarks
  def remove_bookmark(project)
    bookmark_to_remove = self.bookmarks.find_by_project_id(project.id)
    bookmark_to_remove.destroy
    self.update_attribute(:bookmark_blob, "#{self.bookmark_blob}".gsub("|#{project.id}|", ""))
  end
  
  # check if a project is bookmarked
  def bookmarked?(project)
    "#{self.bookmark_blob}".include?("|#{project.id}|")
  end
  
  # refresh the bookmark blob for user
  def refresh_bookmark_blob!
    blob = ""
    self.projects.each do |p|
      blob << "|#{p.id}|"
    end
    self.update_attribute(:bookmark_blob, blob)
  end
  
  # refresh all bookmark blobs for users
  def self.refresh_all_bookmark_blobs
    find(:all).each do |u|
      u.refresh_bookmark_blob!
    end
  end

  # One time show for alerts to send out (new features etc..)
  def show_alert!
    if !self.show_welcome? and self.show_alert?
      self.update_attribute(:show_alert, false)
      return true
    else
      return false
    end
  end
  
  # One time show for welcome message
  def show_welcome!
    if self.show_welcome?
      self.update_attribute(:show_welcome, false)
      return true
    else
      return false
    end
  end
  
  def is_spammer!
    self.spammer = true
    self.save!
    
    self.comments.each{|r| r.destroy}
    self.hosted_instances.each{|r| r.destroy}
    self.screenshots.each{|r| r.destroy}
    self.versions.each{|r| r.destroy}
    self.bookmarks.each{|r| r.destroy}
    self.activities.each{|r| r.destroy}
  end
  
  def open_id?
    !self.identity_url.blank?
  end
  
  def login_editable?
    self.open_id? and self.login.include?("user_")
  end
  
  def email_required?
    signed_up? and !open_id?
  end
  
  def self.clear_spam
    User.find(:all, :conditions => {:spammer => true}).each do |user|
      user.is_spammer!
    end
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank? or !signed_up?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
        
    def password_required?
      signed_up? && (crypted_password.blank? || !password.blank?)
    end
    
    def send_activation_code
      self.deleted_at = nil
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      self.save
      UserMailer.deliver_signup_notification(self)
    end
    
    def do_register
      logger.debug("REGISTERING!")

      if AppConfig.require_email_activation and !self.skip_email
        send_activation_code
      else
        self.activate!
      end
    end
    
    def do_delete
      logger.debug("DELETING!")
      self.deleted_at = Time.now.utc
    end

    def do_activate
      logger.debug("ACTIVATING!")
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
      
      if AppConfig.require_email_activation and !self.skip_email
        UserMailer.deliver_activation_success(self)
      else
        UserMailer.deliver_signup_notification(self)
      end
    end
end
