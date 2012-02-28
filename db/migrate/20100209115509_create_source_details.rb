class CreateSourceDetails < ActiveRecord::Migration
  def self.up
    create_table :source_details do |t|
      t.string :source_code
      t.string :source_english_name
      t.string :source_french_name
      t.string :source_spanish_name

      t.timestamps
    end
  end

  def self.down
    drop_table :source_details
  end
end
