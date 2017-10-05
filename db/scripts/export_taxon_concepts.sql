COPY(
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
  ), accepted_names AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      tc.id AS accepted_name_id,
      CASE WHEN kingdom_name IS NULL THEN FALSE ELSE TRUE END AS has_higher_taxonomy
    FROM cites_eu_taxon_concepts tc
    WHERE name_status IN ('A', 'N')
  ), synonyms AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      (
        ARRAY_AGG_NOTNULL(
          accepted_names.id
          ORDER BY CASE
          WHEN accepted_names.kingdom_name IS NOT NULL THEN 0
          ELSE 1 END
        )::INT[]
      )[1] AS accepted_name_id,
      BOOL_OR(accepted_names.kingdom_name IS NOT NULL) AS has_higher_taxonomy
    FROM cites_eu_taxon_concepts tc
    LEFT JOIN taxon_relationships tr
    ON tr.other_taxon_concept_id = tc.id
    LEFT JOIN taxon_relationship_types trt
    ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_SYNONYM'
    LEFT JOIN cites_eu_taxon_concepts accepted_names
    ON tr.taxon_concept_id = accepted_names.id AND accepted_names.name_status IN ('A', 'N')
    WHERE tc.name_status = 'S'
    GROUP BY tc.id, tc.full_name,
    tc.author_year, tc.name_status, tc.rank_name
  ), trade_names AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      (
        ARRAY_AGG_NOTNULL(
          accepted_names.id
          ORDER BY CASE
          WHEN accepted_names.kingdom_name IS NOT NULL THEN 0
          ELSE 1 END
        )::INT[]
      )[1] AS accepted_name_id,
      BOOL_OR(accepted_names.kingdom_name IS NOT NULL) AS has_higher_taxonomy
    FROM cites_eu_taxon_concepts tc
    LEFT JOIN taxon_relationships tr
    ON tr.other_taxon_concept_id = tc.id
    LEFT JOIN taxon_relationship_types trt
    ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_TRADE_NAME'
    LEFT JOIN cites_eu_taxon_concepts accepted_names
    ON tr.taxon_concept_id = accepted_names.id AND accepted_names.name_status IN ('A', 'N')
    WHERE tc.name_status = 'T'
    GROUP BY tc.id, tc.full_name,
    tc.author_year, tc.name_status, tc.rank_name
  ), hybrids AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      (
        ARRAY_AGG_NOTNULL(
          accepted_names.id
          ORDER BY CASE
          WHEN accepted_names.kingdom_name IS NOT NULL THEN 0
          ELSE 1 END
        )::INT[]
      )[1] AS accepted_name_id,
      BOOL_OR(accepted_names.kingdom_name IS NOT NULL) AS has_higher_taxonomy
    FROM cites_eu_taxon_concepts tc
    LEFT JOIN taxon_relationships tr
    ON tr.other_taxon_concept_id = tc.id
    LEFT JOIN taxon_relationship_types trt
    ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_HYBRID'
    LEFT JOIN cites_eu_taxon_concepts accepted_names
    ON tr.taxon_concept_id = accepted_names.id AND accepted_names.name_status IN ('A', 'N')
    WHERE tc.name_status = 'H'
    GROUP BY tc.id, tc.full_name,
    tc.author_year, tc.name_status, tc.rank_name
  ), names_without_accepted_name_match AS (
    SELECT * FROM accepted_names WHERE NOT has_higher_taxonomy
    UNION
    SELECT * FROM synonyms WHERE NOT has_higher_taxonomy
    UNION
    SELECT * FROM trade_names WHERE NOT has_higher_taxonomy
    UNION
    SELECT * FROM hybrids WHERE NOT has_higher_taxonomy
  ), names_with_best_effort_accepted_name_match AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      (
        ARRAY_AGG_NOTNULL(
          accepted_names.id
          ORDER BY CASE
          WHEN accepted_names.kingdom_name IS NOT NULL THEN 0
          ELSE 1 END
        )::INT[]
      )[1] AS accepted_name_id,
      BOOL_OR(accepted_names.kingdom_name IS NOT NULL) AS has_higher_taxonomy
    FROM names_without_accepted_name_match tc
    JOIN cites_eu_taxon_concepts accepted_names
    ON UPPER(SQUISH_NULL(
      split_part(
        CASE WHEN tc.name_status = 'H' AND strpos(tc.full_name, 'x ') > 0 THEN split_part(tc.full_name, 'x ', 1) ELSE tc.full_name END, ' ', 1
      ))
    ) = UPPER(accepted_names.full_name)
    AND accepted_names.rank_name = 'GENUS'
    WHERE NOT has_higher_taxonomy
    GROUP BY tc.id, tc.full_name,
    tc.author_year, tc.name_status, tc.rank_name
  ), names_with_best_effort_accepted_name_match_pro AS (
    SELECT
      tc.id,
      tc.full_name,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      (
        ARRAY_AGG_NOTNULL(
          accepted_names.id
          ORDER BY CASE
          WHEN accepted_names.kingdom_name IS NOT NULL THEN 0
          ELSE 1 END
        )::INT[]
      )[1] AS accepted_name_id,
      BOOL_OR(accepted_names.kingdom_name IS NOT NULL) AS has_higher_taxonomy
    FROM names_with_best_effort_accepted_name_match tc
    LEFT JOIN taxon_relationships tr
    ON tr.other_taxon_concept_id = tc.id
    LEFT JOIN cites_eu_taxon_concepts accepted_names
    ON accepted_names.id = tr.taxon_concept_id
    LEFT JOIN taxon_relationship_types trt
    ON trt.id = tr.taxon_relationship_type_id
    WHERE NOT has_higher_taxonomy
    GROUP BY tc.id, tc.full_name,
    tc.author_year, tc.name_status, tc.rank_name
  ), taxa_with_higher_taxonomy AS (
    SELECT * FROM accepted_names WHERE has_higher_taxonomy
    UNION
    SELECT * FROM synonyms WHERE has_higher_taxonomy
    UNION
    SELECT * FROM trade_names WHERE has_higher_taxonomy
    UNION
    SELECT * FROM hybrids WHERE has_higher_taxonomy
    UNION
    SELECT * FROM names_with_best_effort_accepted_name_match
    WHERE has_higher_taxonomy
    UNION
    SELECT * FROM names_with_best_effort_accepted_name_match_pro
  ), taxa_with_higher_taxonomy_resolved AS (
    SELECT
      tc.id,
      tc.full_name,
      full_name_with_spp(tc.rank_name, tc.full_name) AS full_name_with_spp,
      tc.author_year,
      tc.name_status,
      tc.rank_name,
      accepted_names.taxonomic_position,
      SQUISH_NULL(accepted_names.data->'genus_name') AS genus_name,
      SQUISH_NULL(accepted_names.data->'family_name') AS family_name,
      SQUISH_NULL(accepted_names.data->'order_name') AS order_name,
      SQUISH_NULL(accepted_names.data->'class_name') AS class_name,
      SQUISH_NULL(accepted_names.data->'phylum_name') AS phylum_name,
      SQUISH_NULL(accepted_names.data->'kingdom_name') AS kingdom_name
    FROM taxa_with_higher_taxonomy tc
    JOIN taxon_concepts accepted_names
    ON accepted_names.id = tc.accepted_name_id
    GROUP BY tc.id, tc.full_name, tc.author_year, tc.name_status, tc.rank_name, taxonomic_position,
    genus_name, family_name, order_name, class_name, phylum_name, kingdom_name, accepted_name_id
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
        WHEN class_name IN ('Actinopteri', 'Elasmobranchii', 'Dipneusti', 'Coelacanthi') THEN 'Fish'
        WHEN class_name IN ('Anthozoa', 'Hydrozoa') THEN 'Corals'
        WHEN kingdom_name = 'Animalia' AND phylum_name != 'Chordata' AND class_name NOT IN ('Anthozoa', 'Hydrozoa') THEN 'Invertebrates (non-corals)'
        WHEN full_name IN ('Chamaeleon', 'Pelophilus') THEN 'Reptiles' -- these synonyms occur in trade and there is no automatic way of inferring the class, because no accepted name is specified
      END AS taxon_group
    FROM taxa_with_higher_taxonomy_resolved tc
  ), taxa_without_higher_taxonomy AS (
    SELECT id, full_name, author_year, name_status, rank_name
    FROM cites_eu_taxon_concepts
    EXCEPT
    SELECT id, full_name, author_year, name_status, rank_name
    FROM taxa_with_higher_taxonomy_resolved
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
