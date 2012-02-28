class CreateTopSpecies < ActiveRecord::Migration
  def self.up
    create_table :top_species do |t|
      t.integer :shipment_year
      t.string :taxon_group
      t.string :term_code
      t.float :quantity
      t.string :source_code
      t.string :import_country_code
      t.string :export_country_code
      t.string :reporter_type
      t.integer :position
      t.float :cites_taxon_code
      t.string :cites_name

      t.timestamps
    end
  end

  def self.down
    drop_table :top_species
  end
end
