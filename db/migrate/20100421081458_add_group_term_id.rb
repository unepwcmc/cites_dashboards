class AddGroupTermId < ActiveRecord::Migration
  def self.up
    add_column :global_trade_summaries, :group_term_id, :integer
    add_column :national_trade_summaries, :group_term_id, :integer
    add_column :species_trade_summaries, :group_term_id, :integer
    add_column :families_trade_summaries, :group_term_id, :integer
    add_column :top_species, :group_term_id, :integer
    add_column :top_families, :group_term_id, :integer
    add_column :top_species, :unit_code, :string
    add_column :top_families, :unit_code, :string
  end

  def self.down
    remove_column :global_trade_summaries, :group_term_id
    remove_column :national_trade_summaries, :group_term_id
    remove_column :species_trade_summaries, :group_term_id
    remove_column :families_trade_summaries, :group_term_id
    remove_column :top_species, :group_term_id
    remove_column :top_families, :group_term_id
    remove_column :top_species, :unit_code
    remove_column :top_families, :unit_code
  end
end
