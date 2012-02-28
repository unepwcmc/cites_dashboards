class LoadPhylumOrder < ActiveRecord::Migration
  def self.up
    down

    #only applies to invertebrates - vertebrates are within single phylum
    execute "INSERT INTO phylum_orders (phylum_name,phylum_listing_order) VALUES ('ECHINODERMATA',1)"
    execute "INSERT INTO phylum_orders (phylum_name,phylum_listing_order) VALUES ('ARTHROPODA',2)"
    execute "INSERT INTO phylum_orders (phylum_name,phylum_listing_order) VALUES ('ANNELIDA',3)"
    execute "INSERT INTO phylum_orders (phylum_name,phylum_listing_order) VALUES ('MOLLUSCA',4)"
    execute "INSERT INTO phylum_orders (phylum_name,phylum_listing_order) VALUES ('CNIDARIA',5)"
  end

  def self.down
    PhylumOrder.delete_all
  end
end
