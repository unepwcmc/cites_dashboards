class AddColumnFullNameToGlobalDetail < ActiveRecord::Migration
  def self.up
    add_column :global_detail, :full_name, :string
  end

  def self.down
    remove_column :global_detail, :full_name
  end
end
