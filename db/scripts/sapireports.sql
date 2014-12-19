COPY(
SELECT 
  CASE
    WHEN reported_by_exporter = TRUE THEN 'E'
    WHEN reported_by_exporter = FALSE THEN 'I'
    ELSE NULL
  END AS reporter_type, 
  year AS shipment_year, 
  appendix,
  NULL AS cites_taxon_code,
  terms.code AS term_code_1,
  units.code AS unit_code_1, 
  sum(quantity), 
  sources.code AS source_code, 
  purposes.code AS purpose_code,
  taxon_concepts.data AS taxo_data,
  taxon_concepts.full_name AS full_name
FROM trade_shipments
  LEFT JOIN taxon_concepts
  ON taxon_concept_id = taxon_concepts.id
  LEFT JOIN (SELECT id, code  FROM trade_codes WHERE type = 'Term') terms
  ON terms.id = term_id
  LEFT JOIN taxon_concepts tc
  ON reported_taxon_concept_id = tc.id
  LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Unit') units
  ON units.id = unit_id
  LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Source') sources
  ON sources.id = source_id
  LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Purpose') purposes
  ON purposes.id = purpose_id
WHERE (purposes.code in ('T','H','P') or purposes.code is null)
  and sources.code <> 'I'
  and importer_id <> exporter_id
  and appendix <> 'N'
  and country_of_origin_id is null
GROUP BY reporter_type, 
       year, 
       appendix,
       term_code_1,
       unit_code_1, 
       source_code, 
       purpose_code,
       taxo_data,
       taxon_concepts.full_name,
       taxon_concepts.id AS taxon_concept_id
order by reporter_type, shipment_year



) TO '/tmp/export_global_dec_2014.csv' WITH CSV

COPY(
SELECT 
  CASE
    WHEN reported_by_exporter = TRUE THEN 'E'
    WHEN reported_by_exporter = FALSE THEN 'I'
    ELSE NULL
  END AS reporter_type, 
  year AS shipment_year, 
  appendix,

  importers.iso_code2 as importer_country_code, 
  exporters.iso_code2 as exporter_country_code, 
  countries_of_origin.iso_code2 as origin_country_code,
  taxon_concepts.t_class AS cites_class,
  terms.code AS term_code_1,
  units.code AS unit_code_1, 
  sum(quantity), 
  sources.code AS source_code, 
  purposes.code AS purpose_code
  taxon_concepts.data AS taxo_data,
  taxon_concepts.full_name AS full_name
FROM trade_shipments
LEFT JOIN taxon_concepts
  ON taxon_concept_id = taxon_concepts.id
LEFT JOIN (SELECT id, iso_code2 FROM geo_entities) importers
ON importer_id = importers.id
LEFT JOIN (SELECT id, iso_code2 FROM geo_entities) exporters
ON exporter_id = exporters.id
LEFT JOIN (SELECT id, iso_code2 FROM geo_entities) countries_of_origin
ON country_of_origin_id = countries_of_origin.id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Term') terms
ON terms.id = term_id
LEFT JOIN taxon_concepts tc
ON reported_taxon_concept_id = tc.id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Unit') units
ON units.id = unit_id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Source') sources
ON sources.id = source_id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Purpose') purposes
ON purposes.id = purpose_id
where (purposes.code in ('T','H','P') or purposes.code is null)
  and sources.code <> 'I'
  and importer_id <> exporter_id
  and appendix <> 'N'
  and year BETWEEN 2007 AND 2013
group by reporter_type, 
       year, 
       appendix,
       importer_country_code,
       exporter_country_code,
       origin_country_code,       
       cites_class,
       term_code_1,
       unit_code_1, 
       source_code, 
       purpose_code
       taxo_data,
       taxon_concepts.full_name
order by reporter_type, year


) TO '/tmp/export_national_07_13_dec_2014.csv' WITH CSV