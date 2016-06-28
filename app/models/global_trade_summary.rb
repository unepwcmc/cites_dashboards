class GlobalTradeSummary < ActiveRecord::Base
  def self.trade_by_year(group, reporter_type, source, term, start_year, end_year)
    if source != nil
      self.sum(:quantity, :group=>:shipment_year, :conditions => ["taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ? and appendix <> 'III'",
                                                                 group,reporter_type,source,term,start_year,end_year])
    else
       self.sum(:quantity, :group=>:shipment_year, :conditions => ["taxon_group = ? and reporter_type = ?  and group_term_id = ? and shipment_year between ? and ?  and appendix <> 'III'",
                                                                   group,reporter_type,term,start_year,end_year])
    end
  end

 def self.maxdate
    2014
  end

  def self.mindate
    1975
  end

  def self.get_filter
    " INNER JOIN group_terms on group_terms.taxon_group = global_trade_summaries.taxon_group and group_terms.term_code = global_trade_summaries.term_code "
  end
end
