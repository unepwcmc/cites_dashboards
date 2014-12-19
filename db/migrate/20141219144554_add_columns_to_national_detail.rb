class AddColumnsToNationalDetail < ActiveRecord::Migration
  def self.up
    add_column :national_detail, :taxo_data, :hstore
    add_column :national_detail, :full_name, :string
    add_column :national_detail, :taxon_concept_id, :integer
  end

  def self.down
    remove_column :national_detail, :taxon_concept_id
    remove_column :national_detail, :full_name
    remove_column :national_detail, :taxo_data
  end
end
