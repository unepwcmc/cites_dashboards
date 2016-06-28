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

COPY taxon_concepts FROM '/tmp/taxon_concepts.csv' DELIMITER ',' CSV;

-- it appears that with the introduction of dodgy taxon concepts into Species+
-- as part of E-Library import, the script now exports some names as duplicates.
-- Typically those are N names, whose parent is a synonym.
-- The following script will delete duplicates, prioritising those with kingdom_name
-- resolved.
WITH duplicate_ids AS (
  SELECT
    id
  FROM taxon_concepts
  GROUP BY id
  HAVING COUNT(id) > 1
), duplicates_in_order AS (
  SELECT
    taxon_concepts.id,
    kingdom_name,
    ROW_NUMBER() OVER (PARTITION BY taxon_concepts.id ORDER BY CASE WHEN kingdom_name IS NOT NULL THEN 0 ELSE 1 END) AS idx
  FROM taxon_concepts
  JOIN duplicate_ids ON duplicate_ids.id = taxon_concepts.id
), duplicates_to_delete AS (
  SELECT
    id
  FROM duplicates_in_order
  WHERE kingdom_name IS NULL AND idx != 1 -- so that we don't delete all if none have kingdom
)
DELETE FROM taxon_concepts
USING duplicates_to_delete
WHERE duplicates_to_delete.id = taxon_concepts.id AND taxon_concepts.kingdom_name IS NULL;


CREATE UNIQUE INDEX ON taxon_concepts (id);
CREATE INDEX ON taxon_concepts(taxon_group);
