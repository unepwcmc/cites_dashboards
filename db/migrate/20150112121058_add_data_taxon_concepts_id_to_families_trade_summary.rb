class AddDataTaxonConceptsIdToFamiliesTradeSummary < ActiveRecord::Migration
  def self.up
    add_column :families_trade_summaries, :taxon_concepts_id, :integer
  end

  def self.down
    remove_column :families_trade_summaries, :taxon_concepts_id
  end
end
