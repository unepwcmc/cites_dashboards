CREATE TABLE new_taxon_code
(
  taxon_concepts_id integer,
  species_kingdom text,
  species_phylum text,
  species_class text,
  species_order text,
  species_family text,
  species_genus text,
  full_name character varying(255),
  name_status character varying(255),
  taxon_group character varying
);

COPY new_taxon_code FROM 'cites_dashboards/db/scripts/csvs_dec2014/new_taxon_code.csv' WITH CSV HEADERS;