class AddTaxonGroupToDistributions < ActiveRecord::Migration
  def self.up
    add_column :species_distributions, :taxon_group, :string
  end

  def self.down
    remove_column :species_distributions, :taxon_group
  end
end
