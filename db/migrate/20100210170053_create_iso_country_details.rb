class CreateIsoCountryDetails < ActiveRecord::Migration
  def self.up
    create_table :iso_country_details do |t|
      t.string :iso_country_code
      t.string :iso_english_short_name
      t.string :iso_english_long_name
      t.string :iso_french_short_name
      t.string :iso_french_long_name
      t.string :iso_spanish_short_name
      t.string :iso_spanish_long_name
      t.string :iso_country_status

      t.timestamps
    end
  end

  def self.down
    drop_table :iso_country_details
  end
end
