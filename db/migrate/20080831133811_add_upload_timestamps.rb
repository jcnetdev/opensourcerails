class AddUploadTimestamps < ActiveRecord::Migration
  def self.up
    add_column :screenshots, :screenshot_updated_at, :datetime
    add_column :versions, :download_updated_at, :datetime
  end

  def self.down
    remove_column :versions, :download_updated_at
    remove_column :screenshots, :screenshot_updated_at
  end
end
