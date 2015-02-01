CREATE VIEW trade_shipments_view AS
SELECT
  trade_shipments.id,
  CASE
    WHEN reported_by_exporter = TRUE THEN 'E'
    ELSE 'I'
  END AS reporter_type,
  year AS shipment_year,
  appendix,
  importers.iso_code2 AS importer_country_code,
  exporters.iso_code2 AS exporter_country_code,
  countries_of_origin.iso_code2 AS origin_country_code,
  terms.code AS term_code,
  units.code AS unit_code,
  quantity,
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
ON purposes.id = purpose_id;

COPY(
  SELECT * FROM trade_shipments_view
  WHERE taxon_concept_id = 141
  ORDER BY shipment_year, exporter_country_code, importer_country_code, origin_country_code
) TO '/tmp/export_trade_in_pholidota.csv' WITH CSV HEADER;

COPY(
  SELECT * FROM trade_shipments_view
  WHERE taxon_concept_id = 29697
  ORDER BY shipment_year, exporter_country_code, importer_country_code, origin_country_code
) TO '/tmp/export_trade_in_chamaeleon.csv' WITH CSV HEADER;

COPY(
  SELECT * FROM trade_shipments_view
  WHERE taxon_concept_id = 30196
  ORDER BY shipment_year, exporter_country_code, importer_country_code, origin_country_code
) TO '/tmp/export_trade_in_pelophilus.csv' WITH CSV HEADER;

CREATE VIEW synonyms_without_accepted_names AS
WITH cites_eu_taxon_concepts AS (
  SELECT
    taxon_concepts.id,
    taxon_concepts.full_name AS full_name,
    author_year,
    name_status,
    taxon_concepts.data->'rank_name' AS rank_name,
    SQUISH_NULL(taxon_concepts.data->'kingdom_name') AS kingdom_name
  FROM taxon_concepts
  JOIN taxonomies ON taxonomies.id = taxonomy_id AND taxonomies.name = 'CITES_EU'
)
SELECT
  tc.id,
  tc.full_name,
  tc.author_year,
  tc.name_status,
  tc.rank_name,
  accepted_names.id AS accepted_id,
  accepted_names.full_name AS accepted_full_name,
  accepted_names.author_year AS accepted_author_year,
  accepted_names.name_status AS accepted_name_status,
  accepted_names.rank_name AS accepted_rank_name
FROM cites_eu_taxon_concepts tc
LEFT JOIN taxon_relationships tr
ON tr.other_taxon_concept_id = tc.id
LEFT JOIN taxon_relationship_types trt
ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_SYNONYM'
LEFT JOIN cites_eu_taxon_concepts accepted_names
ON tr.taxon_concept_id = accepted_names.id
WHERE tc.name_status = 'S'
AND (
  accepted_names.name_status NOT IN ('A', 'N')
  OR accepted_names.id IS NULL
)
ORDER BY tc.full_name;

COPY(
  SELECT * FROM synonyms_without_accepted_names
) TO '/tmp/export_synonyms_without_accepted_names.csv' WITH CSV HEADER;

COPY(
  SELECT * FROM synonyms_without_accepted_names tc
  JOIN trade_shipments_view s
  ON s.taxon_concept_id = tc.id
  ORDER BY tc.full_name, shipment_year
) TO '/tmp/export_trade_in_synonyms_without_accepted_names.csv' WITH CSV HEADER;

DROP VIEW synonyms_without_accepted_names;

CREATE VIEW trade_names_without_accepted_names AS
WITH cites_eu_taxon_concepts AS (
  SELECT
    taxon_concepts.id,
    taxon_concepts.full_name AS full_name,
    author_year,
    name_status,
    taxon_concepts.data->'rank_name' AS rank_name,
    SQUISH_NULL(taxon_concepts.data->'kingdom_name') AS kingdom_name
  FROM taxon_concepts
  JOIN taxonomies ON taxonomies.id = taxonomy_id AND taxonomies.name = 'CITES_EU'
)
SELECT
  tc.id,
  tc.full_name,
  tc.author_year,
  tc.name_status,
  tc.rank_name,
  accepted_names.id AS accepted_id,
  accepted_names.full_name AS accepted_full_name,
  accepted_names.author_year AS accepted_author_year,
  accepted_names.name_status AS accepted_name_status,
  accepted_names.rank_name AS accepted_rank_name
FROM cites_eu_taxon_concepts tc
LEFT JOIN taxon_relationships tr
ON tr.other_taxon_concept_id = tc.id
LEFT JOIN taxon_relationship_types trt
ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_TRADE_NAME'
LEFT JOIN cites_eu_taxon_concepts accepted_names
ON tr.taxon_concept_id = accepted_names.id
WHERE tc.name_status = 'T'
AND (
  accepted_names.name_status NOT IN ('A', 'N')
  OR accepted_names.id IS NULL
)
ORDER BY tc.full_name;

COPY(
  SELECT * FROM trade_names_without_accepted_names
) TO '/tmp/export_trade_names_without_accepted_names.csv' WITH CSV HEADER;

COPY(
  SELECT * FROM trade_names_without_accepted_names tc
  JOIN trade_shipments_view s
  ON s.taxon_concept_id = tc.id
  ORDER BY tc.full_name, shipment_year
) TO '/tmp/export_trade_in_trade_names_without_accepted_names.csv' WITH CSV HEADER;

DROP VIEW trade_names_without_accepted_names;

CREATE VIEW hybrids_without_accepted_names AS
WITH cites_eu_taxon_concepts AS (
  SELECT
    taxon_concepts.id,
    taxon_concepts.full_name AS full_name,
    author_year,
    name_status,
    taxon_concepts.data->'rank_name' AS rank_name,
    SQUISH_NULL(taxon_concepts.data->'kingdom_name') AS kingdom_name
  FROM taxon_concepts
  JOIN taxonomies ON taxonomies.id = taxonomy_id AND taxonomies.name = 'CITES_EU'
)
SELECT
  tc.id,
  tc.full_name,
  tc.author_year,
  tc.name_status,
  tc.rank_name,
  accepted_names.id AS accepted_id,
  accepted_names.full_name AS accepted_full_name,
  accepted_names.author_year AS accepted_author_year,
  accepted_names.name_status AS accepted_name_status,
  accepted_names.rank_name AS accepted_rank_name
FROM cites_eu_taxon_concepts tc
LEFT JOIN taxon_relationships tr
ON tr.other_taxon_concept_id = tc.id
LEFT JOIN taxon_relationship_types trt
ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_HYBRID'
LEFT JOIN cites_eu_taxon_concepts accepted_names
ON tr.taxon_concept_id = accepted_names.id
WHERE tc.name_status = 'H'
AND (
  accepted_names.name_status NOT IN ('A', 'N')
  OR accepted_names.id IS NULL
)
ORDER BY tc.full_name;

COPY(
  SELECT * FROM hybrids_without_accepted_names
) TO '/tmp/export_hybrids_without_accepted_names.csv' WITH CSV HEADER;

COPY(
  SELECT * FROM hybrids_without_accepted_names tc
  JOIN trade_shipments_view s
  ON s.taxon_concept_id = tc.id
  ORDER BY tc.full_name, shipment_year
) TO '/tmp/export_trade_in_hybrids_without_accepted_names.csv' WITH CSV HEADER;

DROP VIEW hybrids_without_accepted_names;

DROP VIEW trade_shipments_view;
