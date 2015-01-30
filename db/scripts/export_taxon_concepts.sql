COPY(
  WITH cites_eu_taxon_concepts AS (
    SELECT
    taxon_concepts.id,
    taxon_concepts.full_name AS full_name,
    full_name_with_spp(taxon_concepts.data->'rank_name', taxon_concepts.full_name) AS full_name_with_spp,
    author_year,
    name_status,
    taxon_concepts.data->'rank_name' AS rank_name,
    taxonomy_id,
    taxonomic_position,
    taxon_concepts.data->'genus_name' AS genus_name,
    taxon_concepts.data->'family_name' AS family_name,
    taxon_concepts.data->'order_name' AS order_name,
    taxon_concepts.data->'class_name' AS class_name,
    taxon_concepts.data->'phylum_name' AS phylum_name,
    taxon_concepts.data->'kingdom_name' AS kingdom_name
    FROM taxon_concepts
    JOIN taxonomies ON taxonomies.id = taxonomy_id AND taxonomies.name = 'CITES_EU'
  ), accepted_names AS (
    SELECT *, tc.id AS accepted_name_id
    FROM cites_eu_taxon_concepts tc
    WHERE name_status IN ('A', 'N')
  ), synonyms_with_accepted_name_match AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.full_name_with_spp,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      tc.taxonomy_id,
      accepted_names.taxonomic_position,
      accepted_names.data->'genus_name',
      accepted_names.data->'family_name',
      accepted_names.data->'order_name',
      accepted_names.data->'class_name',
      accepted_names.data->'phylum_name',
      SQUISH_NULL(accepted_names.data->'kingdom_name') AS kingdom_name,
      accepted_names.id AS accepted_name_id
    FROM cites_eu_taxon_concepts tc
    LEFT JOIN taxon_relationships tr
    ON tr.other_taxon_concept_id = tc.id
    LEFT JOIN taxon_relationship_types trt
    ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_SYNONYM'
    LEFT JOIN taxon_concepts accepted_names
    ON tr.taxon_concept_id = accepted_names.id AND accepted_names.name_status IN ('A', 'N')
    WHERE tc.name_status = 'S'
  ), trade_names_with_accepted_name_match AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.full_name_with_spp,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      tc.taxonomy_id,
      accepted_names.taxonomic_position,
      accepted_names.data->'genus_name',
      accepted_names.data->'family_name',
      accepted_names.data->'order_name',
      accepted_names.data->'class_name',
      accepted_names.data->'phylum_name',
      SQUISH_NULL(accepted_names.data->'kingdom_name') AS kingdom_name,
      accepted_names.id AS accepted_name_id
    FROM cites_eu_taxon_concepts tc
    LEFT JOIN taxon_relationships tr
    ON tr.other_taxon_concept_id = tc.id
    LEFT JOIN taxon_relationship_types trt
    ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_TRADE_NAME'
    LEFT JOIN taxon_concepts accepted_names
    ON tr.taxon_concept_id = accepted_names.id AND accepted_names.name_status IN ('A', 'N')   
    WHERE tc.name_status = 'T'
  ), hybrids_with_accepted_name_match AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.full_name_with_spp,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      tc.taxonomy_id,
      accepted_names.taxonomic_position,
      accepted_names.data->'genus_name',
      accepted_names.data->'family_name',
      accepted_names.data->'order_name',
      accepted_names.data->'class_name',
      accepted_names.data->'phylum_name',
      SQUISH_NULL(accepted_names.data->'kingdom_name') AS kingdom_name,
      accepted_names.id AS accepted_name_id
    FROM cites_eu_taxon_concepts tc
    LEFT JOIN taxon_relationships tr
    ON tr.other_taxon_concept_id = tc.id
    LEFT JOIN taxon_relationship_types trt
    ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_HYBRID'
    LEFT JOIN taxon_concepts accepted_names
    ON tr.taxon_concept_id = accepted_names.id AND accepted_names.name_status IN ('A', 'N')
    WHERE tc.name_status = 'H'
  ), names_without_accepted_name_match AS (
    SELECT * FROM accepted_names WHERE kingdom_name IS NULL
    UNION
    SELECT * FROM synonyms_with_accepted_name_match WHERE kingdom_name IS NULL
    UNION
    SELECT * FROM trade_names_with_accepted_name_match WHERE kingdom_name IS NULL
    UNION
    SELECT * FROM hybrids_with_accepted_name_match WHERE kingdom_name IS NULL
  ), names_with_best_effort_accepted_name_match AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.full_name_with_spp,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      tc.taxonomy_id,
      best_effort_accepted_names.taxonomic_position,
      SQUISH_NULL(best_effort_accepted_names.data->'genus_name') AS genus_name,
      SQUISH_NULL(best_effort_accepted_names.data->'family_name') AS family_name,
      SQUISH_NULL(best_effort_accepted_names.data->'order_name') AS order_name,
      SQUISH_NULL(best_effort_accepted_names.data->'class_name') AS class_name,
      SQUISH_NULL(best_effort_accepted_names.data->'phylum_name') AS phylum_name,
      SQUISH_NULL(best_effort_accepted_names.data->'kingdom_name') AS kingdom_name,
      (
        ARRAY_AGG_NOTNULL(
          best_effort_accepted_names.id
          ORDER BY CASE
          WHEN best_effort_accepted_names.name_status = 'A' THEN 0
          WHEN best_effort_accepted_names.name_status = 'N' THEN 1
          ELSE 2 END
        )::INT[]
      )[1] AS accepted_name_id
    FROM names_without_accepted_name_match tc
    JOIN taxon_concepts best_effort_accepted_names
    ON UPPER(SQUISH_NULL(
      split_part(
        CASE WHEN tc.name_status = 'H' AND strpos(tc.full_name, 'x ') > 0 THEN split_part(tc.full_name, 'x ', 1) ELSE tc.full_name END, ' ', 1
      ))
    ) = UPPER(best_effort_accepted_names.full_name)
    AND tc.taxonomy_id = best_effort_accepted_names.taxonomy_id
    AND best_effort_accepted_names.data->'rank_name' = 'GENUS'
    WHERE kingdom_name IS NULL
    GROUP BY tc.id, tc.full_name, tc.full_name_with_spp,
    tc.author_year, tc.name_status, tc.rank_name, tc.taxonomy_id,
    best_effort_accepted_names.taxonomic_position, best_effort_accepted_names.data
  ), names_with_best_effort_accepted_name_match_pro AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.full_name_with_spp,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      tc.taxonomy_id,
      accepted_names.taxonomic_position,
      accepted_names.data->'genus_name',
      accepted_names.data->'family_name',
      accepted_names.data->'order_name',
      accepted_names.data->'class_name',
      accepted_names.data->'phylum_name',
      SQUISH_NULL(accepted_names.data->'kingdom_name') AS kingdom_name,
      accepted_names.id AS accepted_name_id
    FROM names_with_best_effort_accepted_name_match tc
    LEFT JOIN taxon_relationships tr
    ON tr.other_taxon_concept_id = tc.id
    LEFT JOIN taxon_concepts accepted_names
    ON accepted_names.id = tr.taxon_concept_id
    WHERE kingdom_name IS NULL
  ), taxa_with_higher_taxonomy AS (
    SELECT * FROM accepted_names
    UNION
    SELECT * FROM synonyms_with_accepted_name_match WHERE kingdom_name IS NOT NULL
    UNION
    SELECT * FROM trade_names_with_accepted_name_match WHERE kingdom_name IS NOT NULL
    UNION
    SELECT * FROM hybrids_with_accepted_name_match WHERE kingdom_name IS NOT NULL
    UNION
    SELECT * FROM names_with_best_effort_accepted_name_match
    WHERE kingdom_name IS NOT NULL
    UNION
    SELECT * FROM names_with_best_effort_accepted_name_match_pro
  ), taxa_with_taxon_group AS (
    SELECT *,
    CASE
    WHEN family_name = 'Orchidaceae' THEN 'Orchids'
    WHEN family_name = 'Cactaceae' THEN 'Cacti'
    WHEN kingdom_name = 'Plantae' AND family_name NOT IN ('Orchidaceae', 'Cactaceae') THEN 'Plants (excluding cacti & orchids)'
    WHEN class_name = 'Mammalia' THEN 'Mammals'
    WHEN class_name = 'Aves' THEN 'Birds'
    WHEN class_name = 'Reptilia' THEN 'Reptiles'
    WHEN class_name = 'Amphibia' THEN 'Amphibians'
    WHEN class_name IN ('Actinopterygii', 'Elasmobranchii', 'Sarcopterygii') THEN 'Fish'
    WHEN class_name IN ('Anthozoa', 'Hydrozoa') THEN 'Corals'
    WHEN kingdom_name = 'Animalia' AND phylum_name != 'Chordata' AND class_name NOT IN ('Anthozoa', 'Hydrozoa') THEN 'Invertebrates (non-corals)'
    WHEN full_name IN ('Chamaeleon', 'Pelophilus') THEN 'Reptiles' -- these synonyms occur in trade and there is no automatic way of inferring the class, because no accepted name is specified
    END AS taxon_group
    FROM taxa_with_higher_taxonomy
  ), taxa_without_higher_taxonomy AS (
    SELECT id, full_name, author_year, name_status, rank_name
    FROM cites_eu_taxon_concepts
    EXCEPT
    SELECT id, full_name, author_year, name_status, rank_name
    FROM taxa_with_higher_taxonomy
    WHERE kingdom_name IS NOT NULL
  ), taxa_without_higher_taxonomy_in_trade AS (
    SELECT t.* FROM taxa_without_higher_taxonomy t
    JOIN trade_shipments
    ON trade_shipments.taxon_concept_id = t.id
    GROUP BY t.id, full_name, author_year, name_status, rank_name
  )
  SELECT * FROM taxa_with_taxon_group
  ORDER BY name_status, taxonomic_position
) TO '/tmp/taxon_concepts.csv' WITH CSV;
