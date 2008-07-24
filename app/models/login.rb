class Login < ActiveRecord::BaseWithoutTable
  column :login, :string
  column :password, :string
  column :remember_me, :boolean
  
  validates_presence_of :login, :password
  
  attr_accessor :error_message
  
end