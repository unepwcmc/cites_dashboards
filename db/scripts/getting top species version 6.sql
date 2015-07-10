--IF STANDARDISATION SQL HAS BEEN CHANGED, MAKE SURE NATIONAL-DETAIL IS REFRESHED BEFORE RUNNING THIS.
TRUNCATE top_species;
--SELECT * from top_species
--v. 6:  Need to make sure looking at approved species code

--Can't just do this using limit 10 on the test queries, as want top 10 for each group.  Could use the test queries in the code but that would involve copying national_details to live site
-- country all, source All
INSERT INTO top_species(shipment_year, taxon_group, reporter_type,term_code,unit_code,source_code,import_country_code, export_country_code,taxon_concepts_id, quantity, position,cites_name )
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,source_code,import_country_code,export_country_code, taxon_concepts_id, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,unit_code_1 ORDER BY quantity_1 DESC, taxon_concepts_id) AS pos, full_name_with_spp
     FROM (SELECT reporter_type, CASE
            WHEN shipment_year BETWEEN 2009 AND 2013 THEN 2013
            WHEN shipment_year BETWEEN 2004 AND 2008 THEN 2008
            WHEN shipment_year BETWEEN 1999 AND 2003 THEN 2003
            WHEN shipment_year BETWEEN 1994 AND 1998 THEN 1998
            WHEN shipment_year BETWEEN 1989 AND 1993 THEN 1993
            WHEN shipment_year BETWEEN 1984 AND 1988 THEN 1988
            WHEN shipment_year BETWEEN 1979 AND 1983 THEN 1983
            WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
            ELSE 1900
    END as shipment_year,
    'Global' as import_country_code, 'Global' as export_country_code,
    'All' as source_code,
    --unit_code_1, purpose_code,
    tc.id as taxon_concepts_id, tc.taxon_group, term_code_1,unit_code_1,tc.full_name_with_spp,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group and national_detail.term_code_1 =  group_terms.term_code
        and (national_detail.unit_code_1 = group_terms.unit_code or (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null
    GROUP BY 1,2,3,4,5,6,7,8,9,10) as orig) 
    AS ss
WHERE pos < 11;



-- country all, source Distinct
INSERT INTO top_species(shipment_year, taxon_group, reporter_type,term_code,unit_code,source_code,import_country_code, export_country_code,taxon_concepts_id, quantity, position,cites_name )
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,source_code,import_country_code,export_country_code, taxon_concepts_id, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,unit_code_1, source_code ORDER BY quantity_1 DESC, taxon_concepts_id) AS pos, full_name_with_spp
     FROM (SELECT reporter_type, CASE
            WHEN shipment_year BETWEEN 2009 AND 2013 THEN 2013
            WHEN shipment_year BETWEEN 2004 AND 2008 THEN 2008
            WHEN shipment_year BETWEEN 1999 AND 2003 THEN 2003
            WHEN shipment_year BETWEEN 1994 AND 1998 THEN 1998
            WHEN shipment_year BETWEEN 1989 AND 1993 THEN 1993
            WHEN shipment_year BETWEEN 1984 AND 1988 THEN 1988
            WHEN shipment_year BETWEEN 1979 AND 1983 THEN 1983
            WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
            ELSE 1900
    END as shipment_year,
    'Global' as import_country_code, 'Global' as export_country_code,
    source_code,
    --unit_code_1, purpose_code,
    tc.id as taxon_concepts_id, tc.taxon_group, term_code_1,unit_code_1,tc.full_name_with_spp,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group and national_detail.term_code_1 =  group_terms.term_code
        and (national_detail.unit_code_1 = group_terms.unit_code or (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null
    GROUP BY 1,2,3,4,5,6,7,8,9,10) as orig) 
    AS ss
WHERE pos < 11;


-- Import Country, source All
INSERT INTO top_species(shipment_year, taxon_group, reporter_type,term_code,unit_code,source_code,import_country_code, export_country_code,taxon_concepts_id, quantity, position,cites_name )
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,source_code,import_country_code,export_country_code, taxon_concepts_id, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,unit_code_1, import_country_code ORDER BY quantity_1 DESC, taxon_concepts_id) AS pos, full_name_with_spp
     FROM (SELECT reporter_type, CASE
            WHEN shipment_year BETWEEN 2009 AND 2013 THEN 2013
            WHEN shipment_year BETWEEN 2004 AND 2008 THEN 2008
            WHEN shipment_year BETWEEN 1999 AND 2003 THEN 2003
            WHEN shipment_year BETWEEN 1994 AND 1998 THEN 1998
            WHEN shipment_year BETWEEN 1989 AND 1993 THEN 1993
            WHEN shipment_year BETWEEN 1984 AND 1988 THEN 1988
            WHEN shipment_year BETWEEN 1979 AND 1983 THEN 1983
            WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
            ELSE 1900
    END as shipment_year,
    import_country_code, 'N/A' as export_country_code,
    'All' as source_code,
    --unit_code_1, purpose_code,
    tc.id as taxon_concepts_id, tc.taxon_group, term_code_1,unit_code_1,tc.full_name_with_spp,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group and national_detail.term_code_1 =  group_terms.term_code
        and (national_detail.unit_code_1 = group_terms.unit_code or (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null and reporter_type = 'I'
    GROUP BY 1,2,3,4,5,6,7,8,9,10) as orig) 
    AS ss
WHERE pos < 11;

-- Export Country, source All
INSERT INTO top_species(shipment_year, taxon_group, reporter_type,term_code,unit_code,source_code,import_country_code, export_country_code,taxon_concepts_id, quantity, position,cites_name )
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,source_code,import_country_code,export_country_code, taxon_concepts_id, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,unit_code_1,export_country_code ORDER BY quantity_1 DESC, taxon_concepts_id) AS pos, full_name_with_spp
     FROM (SELECT reporter_type, CASE
            WHEN shipment_year BETWEEN 2009 AND 2013 THEN 2013
            WHEN shipment_year BETWEEN 2004 AND 2008 THEN 2008
            WHEN shipment_year BETWEEN 1999 AND 2003 THEN 2003
            WHEN shipment_year BETWEEN 1994 AND 1998 THEN 1998
            WHEN shipment_year BETWEEN 1989 AND 1993 THEN 1993
            WHEN shipment_year BETWEEN 1984 AND 1988 THEN 1988
            WHEN shipment_year BETWEEN 1979 AND 1983 THEN 1983
            WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
            ELSE 1900
    END as shipment_year,
    'N/A' as import_country_code,export_country_code,
    'All' as source_code,
    --unit_code_1, purpose_code,
    tc.id as taxon_concepts_id, tc.taxon_group, term_code_1,unit_code_1,tc.full_name_with_spp,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group and national_detail.term_code_1 =  group_terms.term_code
        and (national_detail.unit_code_1 = group_terms.unit_code or (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null and reporter_type = 'E'
    GROUP BY 1,2,3,4,5,6,7,8,9,10) as orig) 
    AS ss
WHERE pos < 11;

-- Import Country, source
INSERT INTO top_species(shipment_year, taxon_group, reporter_type,term_code,unit_code,source_code,import_country_code, export_country_code,taxon_concepts_id, quantity, position,cites_name )
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,source_code,import_country_code,export_country_code, taxon_concepts_id, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,unit_code_1, import_country_code, source_code ORDER BY quantity_1 DESC, taxon_concepts_id) AS pos, full_name_with_spp
     FROM (SELECT reporter_type, CASE
            WHEN shipment_year BETWEEN 2009 AND 2013 THEN 2013
            WHEN shipment_year BETWEEN 2004 AND 2008 THEN 2008
            WHEN shipment_year BETWEEN 1999 AND 2003 THEN 2003
            WHEN shipment_year BETWEEN 1994 AND 1998 THEN 1998
            WHEN shipment_year BETWEEN 1989 AND 1993 THEN 1993
            WHEN shipment_year BETWEEN 1984 AND 1988 THEN 1988
            WHEN shipment_year BETWEEN 1979 AND 1983 THEN 1983
            WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
            ELSE 1900
    END as shipment_year,
    import_country_code, 'N/A' as export_country_code,
    source_code,
    --unit_code_1, purpose_code,
    tc.id as taxon_concepts_id, tc.taxon_group, term_code_1,unit_code_1,tc.full_name_with_spp,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group and national_detail.term_code_1 =  group_terms.term_code
        and (national_detail.unit_code_1 = group_terms.unit_code or (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null and reporter_type = 'I'
    GROUP BY 1,2,3,4,5,6,7,8,9,10) as orig) 
    AS ss
WHERE pos < 11;

-- export Country, source
INSERT INTO top_species(shipment_year, taxon_group, reporter_type,term_code,unit_code,source_code,import_country_code, export_country_code,taxon_concepts_id, quantity, position,cites_name )
SELECT *
FROM
  (SELECT shipment_year, taxon_group, reporter_type, term_code_1,unit_code_1,source_code,import_country_code,export_country_code, taxon_concepts_id, quantity_1,
          rank() OVER (PARTITION BY shipment_year, reporter_type,taxon_group,term_code_1,unit_code_1, export_country_code, source_code ORDER BY quantity_1 DESC, taxon_concepts_id) AS pos, full_name_with_spp
     FROM (SELECT reporter_type, CASE
            WHEN shipment_year BETWEEN 2009 AND 2013 THEN 2013
            WHEN shipment_year BETWEEN 2004 AND 2008 THEN 2008
            WHEN shipment_year BETWEEN 1999 AND 2003 THEN 2003
            WHEN shipment_year BETWEEN 1994 AND 1998 THEN 1998
            WHEN shipment_year BETWEEN 1989 AND 1993 THEN 1993
            WHEN shipment_year BETWEEN 1984 AND 1988 THEN 1988
            WHEN shipment_year BETWEEN 1979 AND 1983 THEN 1983
            WHEN shipment_year BETWEEN 1975 AND 1978 THEN 1978
            ELSE 1900
    END as shipment_year,
    'N/A' as import_country_code, export_country_code,
    source_code,
    --unit_code_1, purpose_code,
    tc.id as taxon_concepts_id, tc.taxon_group, term_code_1,unit_code_1,tc.full_name_with_spp,
    SUM(quantity_1) as quantity_1
    FROM national_detail
      inner join taxon_concepts tc on national_detail.taxon_concept_id = tc.id
      inner join group_terms on tc.taxon_group = group_terms.taxon_group and national_detail.term_code_1 =  group_terms.term_code
        and (national_detail.unit_code_1 = group_terms.unit_code or (national_detail.unit_code_1 is null and group_terms.unit_code is null))
    WHERE appendix in ('I','II') AND origin_country_code is null and reporter_type = 'E'
    GROUP BY 1,2,3,4,5,6,7,8,9,10) as orig)
    AS ss
WHERE pos < 11;

--the species data
delete from species_trade_summaries;
insert into species_trade_summaries (shipment_year,appendix,origin_country_code,reporter_type,
  import_country_code,export_country_code,term_code,unit_code,quantity,source_code,purpose_code,
  taxon_group,taxon_concepts_id,cites_name )
select n.shipment_year,appendix,origin_country_code,n.reporter_type,n.import_country_code,n.export_country_code,
term_code_1,unit_code_1,sum(quantity_1),n.source_code,n.purpose_code, tc.taxon_group, tc.id,tc.full_name_with_spp
from national_detail n
  --inner join top_species on national_detail.cites_taxon_code = top_species.cites_taxon_code
  inner join taxon_concepts tc on n.taxon_concept_id = tc.id
  inner join group_terms on tc.taxon_group = group_terms.taxon_group and n.term_code_1 =  group_terms.term_code
    and (n.unit_code_1 = group_terms.unit_code or (n.unit_code_1 is null and group_terms.unit_code is null))
where n.shipment_year < 2013
and EXISTS (SELECT * FROM top_species inner join taxon_concepts c on top_species.taxon_concepts_id = tc.id
where tc.id = n.taxon_concept_id and n.shipment_year BETWEEN top_species.shipment_year - 5 and top_species.shipment_year)
group by n.shipment_year,appendix,origin_country_code,n.reporter_type,n.import_country_code,n.export_country_code,
term_code_1,unit_code_1,n.source_code,n.purpose_code, tc.taxon_group, tc.id,tc.full_name_with_spp;

-- need to make sure the group_term_id is set
update top_species n set group_term_id = t.id from group_terms t
	where (n.taxon_group = t.taxon_group and n.term_code = t.term_code and n.unit_code = t.unit_code)
	  or  (n.taxon_group = t.taxon_group and n.term_code = t.term_code and n.unit_code is null and t.unit_code is null);

update species_trade_summaries n set group_term_id = t.id from group_terms t
	where (n.taxon_group = t.taxon_group and n.term_code = t.term_code and n.unit_code = t.unit_code)
	  or  (n.taxon_group = t.taxon_group and n.term_code = t.term_code and n.unit_code is null and t.unit_code is null);
