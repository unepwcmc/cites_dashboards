-- TO CHECK IF THERE ARE ANY TAXON CONCEPTS WITHOUT TAXON GROUP THAT OCCUR IN TRADE
SELECT * FROM taxon_concepts
JOIN global_detail ON taxon_concepts.id = global_detail.taxon_concept_id
WHERE taxon_group IS NULL;

-- TO CHECK AUTOMATIC MAPPING AGAINST PREVIOUS MAPPING
WITH taxon_concepts_with_incorrect_mapping AS (
SELECT ctc.cites_name, ctc.taxon_group, tc.id, tc.full_name, tc.taxon_group
FROM cites_taxon_codes ctc
LEFT JOIN taxon_concepts tc
ON tc.full_name_with_spp = ctc.cites_name
WHERE tc.taxon_group != ctc.taxon_group OR tc.taxon_group is null
)
SELECT COUNT(*) FROM global_detail
JOIN taxon_concepts_with_incorrect_mapping tc ON tc.id = global_detail.taxon_concept_id;

-- Note: 'Pholidota' is an orchid genus and also an order of mammals
-- quite likely the Trade DB records trade in mammals incorrectly

-- Problematic cases:
-- Pholidota [A] (141)
-- Chamaeleon [S] (29697)
-- Pelophilus [S] (30196)
