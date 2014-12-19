class CreateTableTaxonConcepts < ActiveRecord::Migration
  def self.up
    create_table :taxon_concepts do |t|
      t.integer :taxon_concepts_id
      t.hstore :data
      t.string :full_name
      t.string :name_status

      t.timestamps
    end
  end

  def self.down
    drop_table :taxon_concepts
  end
end
