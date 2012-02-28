class AddUnitCodeToGroupTerms < ActiveRecord::Migration
  def self.up
    add_column :group_terms, :unit_code, :string
  end

  def self.down
    remove_column :group_terms, :unit_code
  end
end
