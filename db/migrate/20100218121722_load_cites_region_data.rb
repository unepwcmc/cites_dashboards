require 'active_record/fixtures'

class LoadCitesRegionData < ActiveRecord::Migration
  def self.up
    down

    directory = File.join(File.dirname(__FILE__),'dev_data')
    Fixtures.create_fixtures(directory, "cites_regions")
  end

  def self.down
    CitesRegion.delete_all
  end
end
