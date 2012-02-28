class CreateTermsDetails < ActiveRecord::Migration
  def self.up
    create_table :terms_details do |t|
      t.string :term_code
      t.string :english_term_name
      t.string :english_explanation
      t.string :french_term_name
      t.string :spanish_term_name

      t.timestamps
    end
  end

  def self.down
    drop_table :terms_details
  end
end
