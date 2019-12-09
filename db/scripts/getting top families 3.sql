TRUNCATE top_families;
--SELECT * from top_families

--Can't just do this using limit 10 on the test queries, as want top 10 for each group.
--Could use the test queries in the code but that would involve copying national_details to live site
--country all, source All
INSERT INTO top_families(shipment_year, taxon_group, reporter_type,term_code,unit_code,
  source_code,import_country_code, export_country_code,taxon_family, quantity, position)
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,
          source_code,import_country_code,export_country_code, family_name, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,
          unit_code_1 ORDER BY quantity_1 DESC, family_name) AS pos
     FROM (SELECT reporter_type, CASE
             WHEN shipment_year BETWEEN 2013 AND 2017 THEN 2017
             WHEN shipment_year BETWEEN 2008 AND 2012 THEN 2012
             WHEN shipment_year BETWEEN 2003 AND 2007 THEN 2007
             WHEN shipment_year BETWEEN 1998 AND 2002 THEN 2002
             WHEN shipment_year BETWEEN 1993 AND 1997 THEN 1997
             WHEN shipment_year BETWEEN 1988 AND 1992 THEN 1992
             WHEN shipment_year BETWEEN 1983 AND 1987 THEN 1987
             WHEN shipment_year BETWEEN 1979 AND 1982 THEN 1982
             WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
             ELSE 1900
    END as shipment_year,
    'Global' as import_country_code, 'Global' as export_country_code,
    'All' as source_code,
    --unit_code_1, purpose_code,
    tc.taxon_group, tc.family_name, term_code_1,unit_code_1,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group
      and national_detail.term_code_1 = group_terms.term_code
      and (national_detail.unit_code_1 = group_terms.unit_code or
        (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null
    AND tc.family_name IS NOT NULL
    GROUP BY 1,2,3,4,5,6,7,8,9) as orig
    ) AS ss
WHERE pos < 11;

-- country all, source Distinct
INSERT INTO top_families(shipment_year, taxon_group, reporter_type,term_code,unit_code,
  source_code,import_country_code, export_country_code,taxon_family, quantity, position)
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,
          source_code,import_country_code,export_country_code, family_name, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,
          unit_code_1, source_code ORDER BY quantity_1 DESC, family_name) AS pos
     FROM (SELECT reporter_type, CASE
             WHEN shipment_year BETWEEN 2013 AND 2017 THEN 2017
             WHEN shipment_year BETWEEN 2008 AND 2012 THEN 2012
             WHEN shipment_year BETWEEN 2003 AND 2007 THEN 2007
             WHEN shipment_year BETWEEN 1998 AND 2002 THEN 2002
             WHEN shipment_year BETWEEN 1993 AND 1997 THEN 1997
             WHEN shipment_year BETWEEN 1988 AND 1992 THEN 1992
             WHEN shipment_year BETWEEN 1983 AND 1987 THEN 1987
             WHEN shipment_year BETWEEN 1979 AND 1982 THEN 1982
             WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
             ELSE 1900
    END as shipment_year,
    'Global' as import_country_code, 'Global' as export_country_code,
    source_code,
    --unit_code_1, purpose_code,
    tc.taxon_group, tc.family_name, term_code_1,unit_code_1,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group
      and national_detail.term_code_1 = group_terms.term_code
      and (national_detail.unit_code_1 = group_terms.unit_code or
        (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null
    AND tc.family_name IS NOT NULL
    GROUP BY 1,2,3,4,5,6,7,8,9) as orig
    ) AS ss
WHERE pos < 11;


-- Import Country, source All
INSERT INTO top_families(shipment_year, taxon_group, reporter_type,term_code,unit_code,
  source_code,import_country_code, export_country_code,taxon_family, quantity, position)
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,
          source_code,import_country_code,export_country_code, family_name, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,
          unit_code_1, import_country_code ORDER BY quantity_1 DESC, family_name) AS pos
     FROM (SELECT reporter_type, CASE
             WHEN shipment_year BETWEEN 2013 AND 2017 THEN 2017
             WHEN shipment_year BETWEEN 2008 AND 2012 THEN 2012
             WHEN shipment_year BETWEEN 2003 AND 2007 THEN 2007
             WHEN shipment_year BETWEEN 1998 AND 2002 THEN 2002
             WHEN shipment_year BETWEEN 1993 AND 1997 THEN 1997
             WHEN shipment_year BETWEEN 1988 AND 1992 THEN 1992
             WHEN shipment_year BETWEEN 1983 AND 1987 THEN 1987
             WHEN shipment_year BETWEEN 1979 AND 1982 THEN 1982
             WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
             ELSE 1900
    END as shipment_year,
    import_country_code, 'N/A' as export_country_code,
    'All' as source_code,
    --unit_code_1, purpose_code,
    tc.taxon_group, tc.family_name, term_code_1,unit_code_1,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group
      and national_detail.term_code_1 = group_terms.term_code
      and (national_detail.unit_code_1 = group_terms.unit_code or
        (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null and reporter_type = 'I'
    AND tc.family_name IS NOT NULL
    GROUP BY 1,2,3,4,5,6,7,8,9) as orig
    ) AS ss
WHERE pos < 11;

-- Export Country, source All
INSERT INTO top_families(shipment_year, taxon_group, reporter_type,term_code,unit_code,
  source_code,import_country_code, export_country_code,taxon_family, quantity, position)
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,
          source_code,import_country_code,export_country_code, family_name, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,
          unit_code_1, export_country_code ORDER BY quantity_1 DESC, family_name) AS pos
     FROM (SELECT reporter_type, CASE
             WHEN shipment_year BETWEEN 2013 AND 2017 THEN 2017
             WHEN shipment_year BETWEEN 2008 AND 2012 THEN 2012
             WHEN shipment_year BETWEEN 2003 AND 2007 THEN 2007
             WHEN shipment_year BETWEEN 1998 AND 2002 THEN 2002
             WHEN shipment_year BETWEEN 1993 AND 1997 THEN 1997
             WHEN shipment_year BETWEEN 1988 AND 1992 THEN 1992
             WHEN shipment_year BETWEEN 1983 AND 1987 THEN 1987
             WHEN shipment_year BETWEEN 1979 AND 1982 THEN 1982
             WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
             ELSE 1900
    END as shipment_year,
    'N/A' as import_country_code,export_country_code,
    'All' as source_code,
    --unit_code_1, purpose_code,
    tc.taxon_group, tc.family_name, term_code_1,unit_code_1,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group
      and national_detail.term_code_1 = group_terms.term_code
      and (national_detail.unit_code_1 = group_terms.unit_code or
        (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null and reporter_type = 'E'
    AND tc.family_name IS NOT NULL
    GROUP BY 1,2,3,4,5,6,7,8,9) as orig
    ) AS ss
WHERE pos < 11;

-- Import Country, source
INSERT INTO top_families(shipment_year, taxon_group, reporter_type,term_code,unit_code,
  source_code,import_country_code, export_country_code,taxon_family, quantity, position)
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,
          source_code,import_country_code,export_country_code, family_name, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,
          unit_code_1, import_country_code,source_code ORDER BY quantity_1 DESC, family_name) AS pos
     FROM (SELECT reporter_type, CASE
             WHEN shipment_year BETWEEN 2013 AND 2017 THEN 2017
             WHEN shipment_year BETWEEN 2008 AND 2012 THEN 2012
             WHEN shipment_year BETWEEN 2003 AND 2007 THEN 2007
             WHEN shipment_year BETWEEN 1998 AND 2002 THEN 2002
             WHEN shipment_year BETWEEN 1993 AND 1997 THEN 1997
             WHEN shipment_year BETWEEN 1988 AND 1992 THEN 1992
             WHEN shipment_year BETWEEN 1983 AND 1987 THEN 1987
             WHEN shipment_year BETWEEN 1979 AND 1982 THEN 1982
             WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
             ELSE 1900
    END as shipment_year,
    import_country_code, 'N/A' as export_country_code,
    source_code,
    --unit_code_1, purpose_code,
    tc.taxon_group, tc.family_name, term_code_1,unit_code_1,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group
      and national_detail.term_code_1 = group_terms.term_code
      and (national_detail.unit_code_1 = group_terms.unit_code or
        (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null and reporter_type = 'I'
    AND tc.family_name IS NOT NULL
    GROUP BY 1,2,3,4,5,6,7,8,9) as orig
    ) AS ss
WHERE pos < 11;

-- export Country, source
INSERT INTO top_families(shipment_year, taxon_group, reporter_type,term_code,unit_code,
  source_code,import_country_code, export_country_code,taxon_family, quantity, position)
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,
          source_code,import_country_code,export_country_code, family_name, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,
          unit_code_1, export_country_code,source_code ORDER BY quantity_1 DESC, family_name) AS pos
     FROM (SELECT reporter_type, CASE
             WHEN shipment_year BETWEEN 2013 AND 2017 THEN 2017
             WHEN shipment_year BETWEEN 2008 AND 2012 THEN 2012
             WHEN shipment_year BETWEEN 2003 AND 2007 THEN 2007
             WHEN shipment_year BETWEEN 1998 AND 2002 THEN 2002
             WHEN shipment_year BETWEEN 1993 AND 1997 THEN 1997
             WHEN shipment_year BETWEEN 1988 AND 1992 THEN 1992
             WHEN shipment_year BETWEEN 1983 AND 1987 THEN 1987
             WHEN shipment_year BETWEEN 1979 AND 1982 THEN 1982
             WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
             ELSE 1900
    END as shipment_year,
    'N/A' as import_country_code, export_country_code,
    source_code,
    --unit_code_1, purpose_code,
    tc.taxon_group, tc.family_name, term_code_1,unit_code_1,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group
      and national_detail.term_code_1 = group_terms.term_code
      and (national_detail.unit_code_1 = group_terms.unit_code or
        (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null and reporter_type = 'E'
    AND tc.family_name IS NOT NULL
    GROUP BY 1,2,3,4,5,6,7,8,9) as orig
    ) AS ss
WHERE pos < 11;



--The family data
TRUNCATE families_trade_summaries;
insert into families_trade_summaries (shipment_year,appendix,origin_country_code,reporter_type,
  import_country_code,export_country_code,term_code,unit_code,quantity,source_code,purpose_code,
  taxon_group,taxon_family )
select n.shipment_year,appendix,origin_country_code,n.reporter_type,n.import_country_code,
  n.export_country_code,term_code_1,unit_code_1,sum(quantity_1),n.source_code,n.purpose_code,
  taxon_concepts.taxon_group, taxon_concepts.family_name
from national_detail n
  --inner join top_families on national_detail.cites_taxon_code = top_families.cites_taxon_code
  inner join taxon_concepts on n.taxon_concept_id = taxon_concepts.id
  inner join group_terms on taxon_concepts.taxon_group = group_terms.taxon_group and
    n.term_code_1 = group_terms.term_code
  and (n.unit_code_1 = group_terms.unit_code or (n.unit_code_1 is null and group_terms.unit_code is null))
where n.shipment_year < 2018
  and EXISTS (SELECT * FROM top_families where top_families.taxon_family = taxon_concepts.family_name
  and n.shipment_year BETWEEN top_families.shipment_year - 5 and top_families.shipment_year)
  AND taxon_concepts.family_name IS NOT NULL
group by n.shipment_year,appendix,origin_country_code,n.reporter_type,n.import_country_code,
  n.export_country_code,term_code_1,unit_code_1,n.source_code,n.purpose_code, taxon_concepts.taxon_group,
  taxon_concepts.family_name;

update top_families n set group_term_id = t.id from group_terms t
  where (n.taxon_group = t.taxon_group and n.term_code = t.term_code
    and n.unit_code = t.unit_code)
    or  (n.taxon_group = t.taxon_group and n.term_code = t.term_code
      and n.unit_code is null and t.unit_code is null);

update families_trade_summaries n set group_term_id = t.id from group_terms t
  where (n.taxon_group = t.taxon_group and n.term_code = t.term_code
    and n.unit_code = t.unit_code)
    or  (n.taxon_group = t.taxon_group and n.term_code = t.term_code
      and n.unit_code is null and t.unit_code is null);
