class AddColumn < ActiveRecord::Migration
  def self.up
    add_column :global_detail, :taxo_data, :hstore
  end

  def self.down
    remove_column :global_detail, :taxo_data
  end
end
