class CreatePhylumOrders < ActiveRecord::Migration
  def self.up
    create_table :phylum_orders do |t|
      t.string :phylum_name
      t.integer :phylum_listing_order

      t.timestamps
    end
  end

  def self.down
    drop_table :phylum_orders
  end
end
