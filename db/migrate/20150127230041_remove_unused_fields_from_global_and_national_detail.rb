class RemoveUnusedFieldsFromGlobalAndNationalDetail < ActiveRecord::Migration
  def self.up
    remove_column :global_detail, :cites_taxon_code
    remove_column :global_detail, :taxo_data
    remove_column :national_detail, :cites_taxon_code
    remove_column :national_detail, :taxo_data
  end

  def self.down
    add_column :global_detail, :cites_taxon_code, :double
    add_column :global_detail, :taxo_data, :hstore
    add_column :national_detail, :cites_taxon_code, :double
    add_column :national_detail, :taxo_data, :hstore
  end
end
