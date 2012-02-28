class CreateTradingCountries < ActiveRecord::Migration
  def self.up
    create_table :trading_countries, {:id => false} do |t|
      t.string :name
      t.string :iso_country_code
      t.integer :entry_date
      t.integer :cites_region_code
      t.string  :dependency_of
      t.boolean :exclude_from_selection, :default => false

      t.timestamps
    end
    execute "ALTER TABLE trading_countries ADD PRIMARY KEY (iso_country_code);"   
  end

  def self.down
    drop_table :trading_countries
  end
end
