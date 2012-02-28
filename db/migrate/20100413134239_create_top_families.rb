class CreateTopFamilies < ActiveRecord::Migration
  def self.up
    create_table :top_families do |t|
      t.integer :shipment_year
      t.string :taxon_group
      t.string :term_code
      t.float :quantity
      t.string :source_code
      t.string :import_country_code
      t.string :export_country_code
      t.string :reporter_type
      t.integer :position
      t.string :taxon_family

      t.timestamps
    end
  end

  def self.down
    drop_table :top_families
  end
end
