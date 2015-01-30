DROP TABLE IF EXISTS taxon_concepts;

CREATE TABLE taxon_concepts (
  id INT,
  full_name TEXT,
  full_name_with_spp TEXT,
  author_year TEXT,
  name_status TEXT,
  rank_name TEXT,
  taxonomy_id INT,
  taxonomic_position TEXT,
  genus_name TEXT,
  family_name TEXT,
  order_name TEXT,
  class_name TEXT,
  phylum_name TEXT,
  kingdom_name TEXT,
  accepted_name_id INT,
  taxon_group TEXT
);

COPY taxon_concepts FROM '/tmp/taxon_concepts.csv'  DELIMITER ',' CSV;


-- TO CHECK AUTOMATIC MAPPING
SELECT ctc.cites_name, ctc.taxon_group, tc.full_name, tc.taxon_group
FROM cites_taxon_codes ctc
LEFT JOIN new_taxon_concepts tc
ON tc.full_name_with_spp = ctc.cites_name
WHERE tc.taxon_group != ctc.taxon_group OR tc.taxon_group is null
