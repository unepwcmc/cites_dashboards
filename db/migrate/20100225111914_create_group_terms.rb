class CreateGroupTerms < ActiveRecord::Migration
  def self.up
    create_table :group_terms do |t|
      t.string :taxon_group
      t.string :term_code
      t.string :term_description

      t.timestamps
    end
  end

  def self.down
    drop_table :group_terms
  end
end
