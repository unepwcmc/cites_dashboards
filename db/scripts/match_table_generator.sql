COPY(SELECT id as taxon_concepts_id, full_name, name_status, data FROM taxon_concepts) TO '/tmp/taxon_concepts.csv' WITH CSV;


DELETE FROM taxon_concepts;

COPY taxon_concepts FROM '/tmp/taxon_concepts.csv'  DELIMITER ',' CSV;

CREATE INDEX full_name_idx ON taxon_concepts(full_name);
CREATE INDEX genus_name_idx ON cites_taxon_codes(taxon_genus);
DROP TABLE new_taxon_code;


CREATE TABLE new_taxon_code AS
SELECT DISTINCT * FROM (
SELECT taxon_concepts_id, 
       data -> 'kingdom_name' AS species_kingdom,
       data -> 'phylum_name' AS species_phylum,
       data -> 'class_name' AS species_class,
       data -> 'order_name' AS species_order,
       data -> 'family_name' AS species_family,
       data -> 'genus_name' AS species_genus,
       full_name,
       name_status,
       taxon_group
       FROM cites_taxon_codes ctc
       JOIN taxon_concepts tc
       ON tc.name_status in ('A', 'N') AND LOWER(tc.data->'genus_name') = LOWER(taxon_genus)
       UNION
       SELECT taxon_concepts_id, 
              data -> 'kingdom_name' AS species_kingdom,
              data -> 'phylum_name' AS species_phylum,
              data -> 'class_name' AS species_class,
              data -> 'order_name' AS species_order,
              data -> 'family_name' AS species_family,
              data -> 'genus_name' AS species_genus,
              full_name,
              name_status,
              taxon_group
       FROM cites_taxon_codes ctc
       JOIN taxon_concepts tc
       ON tc.name_status = 'H' AND LOWER(split_part(tc.full_name, ' ', 1) )= LOWER(taxon_genus)
) a


COPY(
SELECT distinct taxon_group,
       tc.name_status,
       tc.taxon_concepts_id
  taxo_data -> 'kingdom_name' AS species_kingdom,
       taxo_data -> 'class_name' AS species_class,
       taxo_data -> 'order_name' AS species_order,
       taxo_data -> 'family_name' AS species_family,
       taxo_data -> 'genus_name' AS species_genus,
       
 FROM
global_detail gd
LEFT Join new_taxon_code ntc
ON gd.taxon_concept_id = ntc.taxon_concepts_id
LEFT Join taxon_concepts tc
ON gd.taxon_concept_id = tc.taxon_concepts_id

) to '/tmp/matching_species_cites_dashboard_".csv'
WITH DELIMITER ','
CSV HEADER

--- Adds missing taxa 

INSERT INTO new_taxon_code (taxon_concepts_id, species_kingdom, species_phylum, species_class, species_order, species_family, species_genus, full_name, name_status, taxon_group)
SELECT taxon_concept_id,        higher_taxa -> 'kingdom_name' AS species_kingdom,
       higher_taxa -> 'phylum_name' AS species_phylum,
       higher_taxa -> 'class_name' AS species_class,
       higher_taxa -> 'order_name' AS species_order,
       higher_taxa -> 'family_name' AS species_family,
       higher_taxa -> 'genus_name' AS species_genus, name, '', taxon_group
       FROM missing_species 