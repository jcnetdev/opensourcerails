class AddUserFields < ActiveRecord::Migration
  def self.up
    add_column :users, :tell_friend_count, :integer, :default => 0
    add_column :users, :tell_friend_last_sent, :datetime
  end

  def self.down
    remove_column :users, :tell_friend_last_sent
    remove_column :users, :tell_friend_count
  end
end
