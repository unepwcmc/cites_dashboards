class AddAppendixToGlobalSummary < ActiveRecord::Migration
  def self.up
    add_column :global_trade_summaries, :appendix, :string
  end

  def self.down
    remove_column :global_trade_summaries, :appendix
  end
end
