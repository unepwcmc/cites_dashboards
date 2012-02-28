class CreateGlobalTradeSummaries < ActiveRecord::Migration
  def self.up
    create_table :global_trade_summaries do |t|
      t.string :reporter_type
      t.integer :shipment_year
      t.string :taxon_group 
      t.string :term_code
      t.string :unit_code
      t.float :quantity
      t.string :source_code
      t.string :purpose_code

      t.timestamps
    end
  end

  def self.down
    drop_table :global_trade_summaries
  end
end
