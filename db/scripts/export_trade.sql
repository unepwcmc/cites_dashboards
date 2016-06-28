DROP VIEW IF EXISTS trade_shipments_for_global_detail;

CREATE VIEW trade_shipments_for_global_detail AS
SELECT
  CASE
    WHEN reported_by_exporter = TRUE THEN 'E'
    ELSE 'I'
  END AS reporter_type,
  year AS shipment_year,
  appendix,
  terms.code AS term_code_1,
  units.code AS unit_code_1,
  sum(quantity) AS quantity_1,
  sources.code AS source_code,
  purposes.code AS purpose_code,
  full_name_with_spp(tc.data->'rank_name', tc.full_name) AS full_name_with_spp,
  tc.full_name AS full_name,
  COALESCE(tc.data->'genus_name', split_part(full_name, ' ', 1)) AS genus_name,
  data->'family_name' AS family_name,
  data->'order_name' AS order_name,
  data->'class_name' AS class_name,
  data->'phylum_name' AS phylum_name,
  data->'kingdom_name' AS kingdom_name,
  taxon_concept_id
FROM trade_shipments
-- taxon_concept_id is a required field
INNER JOIN taxon_concepts tc
ON taxon_concept_id = tc.id
-- term_id is a required field
INNER JOIN (SELECT id, code FROM trade_codes WHERE type = 'Term') terms
ON terms.id = term_id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Unit') units
ON units.id = unit_id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Source') sources
ON sources.id = source_id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Purpose') purposes
ON purposes.id = purpose_id
WHERE (purposes.code in ('T','H','P') OR purposes.code IS NULL)
  AND (sources.code <> 'I' OR sources.code IS NULL)
  AND importer_id <> exporter_id -- both required fields
  AND appendix <> 'N' -- required field
  AND country_of_origin_id IS NULL
GROUP BY reporter_type,
  year,
  appendix,
  taxon_concept_id,
  tc.full_name,
  tc.data,
  term_code_1,
  unit_code_1,
  source_code,
  purpose_code
ORDER BY reporter_type, year;

COPY(
  SELECT * FROM trade_shipments_for_global_detail
) TO '/tmp/export_global.csv' WITH CSV;

DROP VIEW IF EXISTS trade_shipments_for_global_detail;

DROP VIEW IF EXISTS trade_shipments_for_national_detail;

CREATE VIEW trade_shipments_for_national_detail AS
SELECT
  CASE
    WHEN reported_by_exporter = TRUE THEN 'E'
    ELSE 'I'
  END AS reporter_type,
  year AS shipment_year,
  appendix,
  importers.iso_code2 AS importer_country_code,
  exporters.iso_code2 AS exporter_country_code,
  countries_of_origin.iso_code2 AS origin_country_code,
  terms.code AS term_code_1,
  units.code AS unit_code_1,
  sum(quantity),
  sources.code AS source_code,
  purposes.code AS purpose_code,
  full_name_with_spp(tc.data->'rank_name', tc.full_name) AS full_name_with_spp,
  tc.full_name AS full_name,
  COALESCE(tc.data->'genus_name', split_part(full_name, ' ', 1)) AS genus_name,
  data->'family_name' AS family_name,
  data->'order_name' AS order_name,
  data->'class_name' AS class_name,
  data->'phylum_name' AS phylum_name,
  data->'kingdom_name' AS kingdom_name,
  taxon_concept_id
FROM trade_shipments
INNER JOIN taxon_concepts tc
  ON taxon_concept_id = tc.id
INNER JOIN (SELECT id, iso_code2 FROM geo_entities) importers
ON importer_id = importers.id
INNER JOIN (SELECT id, iso_code2 FROM geo_entities) exporters
ON exporter_id = exporters.id
INNER JOIN (SELECT id, code FROM trade_codes WHERE type = 'Term') terms
ON terms.id = term_id
LEFT JOIN (SELECT id, iso_code2 FROM geo_entities) countries_of_origin
ON country_of_origin_id = countries_of_origin.id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Unit') units
ON units.id = unit_id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Source') sources
ON sources.id = source_id
LEFT JOIN (SELECT id, code FROM trade_codes WHERE type = 'Purpose') purposes
ON purposes.id = purpose_id
WHERE (purposes.code in ('T','H','P') OR purposes.code IS NULL)
  AND (sources.code <> 'I' OR sources.code IS NULL)
  AND importer_id <> exporter_id
  AND appendix <> 'N'
GROUP BY reporter_type,
  year,
  appendix,
  taxon_concept_id,
  tc.full_name,
  tc.data,
  importer_country_code,
  exporter_country_code,
  origin_country_code,
  term_code_1,
  unit_code_1,
  source_code,
  purpose_code
ORDER BY reporter_type, year;

COPY(
  SELECT * FROM trade_shipments_for_national_detail
  WHERE shipment_year < 1990
) TO '/tmp/export_national_1990.csv' WITH CSV;

COPY(
  SELECT * FROM trade_shipments_for_national_detail
  WHERE shipment_year >= 1990 AND shipment_year < 2000
) TO '/tmp/export_national_1990_2000.csv' WITH CSV;

COPY(
  SELECT * FROM trade_shipments_for_national_detail
  WHERE shipment_year >= 2000 AND shipment_year < 2010
) TO '/tmp/export_national_2000_2010.csv' WITH CSV;

COPY(
  SELECT * FROM trade_shipments_for_national_detail
  WHERE shipment_year >= 2010
) TO '/tmp/export_national_2010.csv' WITH CSV;

DROP VIEW IF EXISTS trade_shipments_for_national_detail;
