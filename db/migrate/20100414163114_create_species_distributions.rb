class CreateSpeciesDistributions < ActiveRecord::Migration
  def self.up
    create_table :species_distributions do |t|
      t.string :kingdom_name
      t.string :kingdom_common_name
      t.string :phylum_name
      t.string :class_name
      t.string :order_name
      t.string :family_name
      t.string :genus_name
      t.string :species_name
      t.string :species_subname
      t.string :species_author
      t.string :country

      t.timestamps
    end
  end

  def self.down
    drop_table :species_distributions
  end
end
