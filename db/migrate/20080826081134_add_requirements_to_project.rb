class AddRequirementsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :requirements, :string
  end

  def self.down
    remove_column :projects, :requirements
  end
end
