class Login < ActiveRecord::BaseWithoutTable
  column :username, :string
  column :password, :string
  column :remember_me, :boolean
  
  validates_presence_of :username, :password
  
  attr_accessor :error_message
  
end