class CreateCitesRegions < ActiveRecord::Migration
  def self.up
    create_table :cites_regions, {:id => false} do |t|
      t.integer :cites_region_code
      t.string :cites_region_name

      t.timestamps
    end
    execute "ALTER TABLE cites_regions ADD PRIMARY KEY (cites_region_code);" 
  end

  def self.down
    drop_table :cites_regions
  end
end
