class AddDataToTaxonConcept < ActiveRecord::Migration
  def self.up
    add_column :taxon_concepts, :data, :hstore
  end

  def self.down
    remove_column :taxon_concepts, :data
  end
end
