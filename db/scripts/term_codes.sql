update national_trade_summaries n set group_term_id = t.id from group_terms t 
  where (n.taxon_group = t.taxon_group and n.term_code = t.term_code and n.unit_code = t.unit_code)
    or  (n.taxon_group = t.taxon_group and n.term_code = t.term_code and n.unit_code is null and t.unit_code is null);

update global_trade_summaries n set group_term_id = t.id from group_terms t 
  where (n.taxon_group = t.taxon_group and n.term_code = t.term_code and n.unit_code = t.unit_code)
    or  (n.taxon_group = t.taxon_group and n.term_code = t.term_code and n.unit_code is null and t.unit_code is null);