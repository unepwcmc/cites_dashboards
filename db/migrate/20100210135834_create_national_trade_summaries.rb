class CreateNationalTradeSummaries < ActiveRecord::Migration
  def self.up
    create_table :national_trade_summaries do |t|
      t.integer :shipment_year
      t.string :taxon_group
      t.string :term_code
      t.string :unit_code
      t.float :quantity
      t.string :source_code
      t.string :purpose_code
      t.string :import_country_code
      t.string :export_country_code
      t.string :reporter_type

      t.timestamps
    end
  end

  def self.down
    drop_table :national_trade_summaries
  end
end
