DROP TABLE IF EXISTS taxon_concepts;

CREATE TABLE taxon_concepts (
  id INT,
  full_name TEXT,
  full_name_with_spp TEXT,
  author_year TEXT,
  name_status TEXT,
  rank_name TEXT,
  taxonomic_position TEXT,
  genus_name TEXT,
  family_name TEXT,
  order_name TEXT,
  class_name TEXT,
  phylum_name TEXT,
  kingdom_name TEXT,
  taxon_group TEXT
);

COPY taxon_concepts FROM '/tmp/taxon_concepts.csv'  DELIMITER ',' CSV;

CREATE UNIQUE INDEX ON taxon_concepts (id);
CREATE INDEX ON taxon_concepts(taxon_group);
