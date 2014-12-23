class AddTaxonConceptIdToGlobalDetail < ActiveRecord::Migration
  def self.up
    add_column :global_detail, :taxon_concept_id, :integer
  end

  def self.down
    remove_column :global_detail, :taxon_concept_id
  end
end
