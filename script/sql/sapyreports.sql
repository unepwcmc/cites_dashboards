SELECT reported_by_exporter, year, appendix, 'taxon_code' as taxon_code,terms.code, units.code, sum(quantity), sources.code, purposes.code
FROM trade_shipments
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
  and country_of_origin_id is null
group by reported_by_exporter, 
       year, 
       appendix,
       taxon_code,
       terms.code,
       units.code, 
       sources.code, 
       purposes.code
order by reported_by_exporter, year;

SELECT reported_by_exporter, year, appendix, importers.iso_code2 as importer_country_code, exporters.iso_code2 as exporter_country_code, countries_of_origin.iso_code2 as origin_country_code, 'taxon_code' as taxon_code,terms.code, units.code, sum(quantity), sources.code, purposes.code
FROM trade_shipments
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
  and year BETWEEN 2001 AND 2008
group by reported_by_exporter, 
       year, 
       appendix,
       importer_country_code,
       exporter_country_code,
       origin_country_code,       
       taxon_code,
       terms.code,
       units.code, 
       sources.code, 
       purposes.code
order by reported_by_exporter, year;
