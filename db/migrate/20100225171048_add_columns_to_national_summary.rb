class AddColumnsToNationalSummary < ActiveRecord::Migration
  def self.up
    add_column :national_trade_summaries, :appendix, :string
    add_column :national_trade_summaries, :origin_country_code, :string
  end

  def self.down
    remove_column :national_trade_summaries, :appendix
    remove_column :national_trade_summaries, :origin_country_code
  end
end
