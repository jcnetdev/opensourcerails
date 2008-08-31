class CleanupScreenshotSchema < ActiveRecord::Migration
  def self.up
    remove_column :screenshots, :size
    remove_column :screenshots, :content_type
    remove_column :screenshots, :filename

    remove_column :versions, :size
    remove_column :versions, :content_type
    remove_column :versions, :filename
  end

  def self.down
    add_column :versions, :filename, :string
    add_column :versions, :content_type, :string
    add_column :versions, :size, :integer

    add_column :screenshots, :filename, :string
    add_column :screenshots, :content_type, :string
    add_column :screenshots, :size, :integer
  end
end
