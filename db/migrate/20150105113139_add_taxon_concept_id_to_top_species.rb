class AddTaxonConceptIdToTopSpecies < ActiveRecord::Migration
  def self.up
    add_column :top_species, :taxon_concepts_id, :integer
  end

  def self.down
    remove_column :top_species, :taxon_concepts_id
  end
end
