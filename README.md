# CITES Dashboards

CITES Trade Data Dashboards (http://dashboards.cites.org/national) provide and overview of CITES trade data.

## Steps required to update the CITES Dashboards:
  - obtain a fresh copy of both the Species+ & CITES Trade db and last CITES Dashboards db and install them locally; do not run these scripts on production machines
  - export data from Species+ and CITES Trade db
    * export trade in format ready for global / national details: db/scripts/export_trade.sql
    * export list of taxon concepts with automatic mapping to dashboard taxon groups: db/scripts/export_taxon_concepts.sql
  - import taxon concepts
    * import taxon concepts: import_taxon_concepts.sql
    * VERIFY the automatic mapping by running db/scripts/verify_taxon_groups.sql - in case there are taxa in trade that do not map automatically to CITES dashboards taxon groups, do not proceed until that is resolved by either amending data in Species+ or a workaround in the export_taxon_concepts script
  - import global & national details and aggregate data
    * Make sure the values on the end of 'importing_global.sql' and 'importing_national.sql' match the years you want to import
    * Use the file 'importing_global.sql' to import the global data
    * Use the file 'importing_national.sql' to import the national data
    * Run 'getting top species' and 'getting top families'

## About taxon groups

This is the definition of taxon groups:

| Group                               | Taxon rank  | Taxon name                                                                                    |
|------------------------------------ |------------ |---------------------------------------------------------------------------------------------- |
| Mammals                             | Class       | Mammalia                                                                                      |
| Birds                               | Class       | Aves                                                                                          |
| Reptiles                            | Class       | Reptilia                                                                                      |
| Amphibians                          | Class       | Amphibia                                                                                      |
| Fish                                | 3 x Class   | Actinopterygii, Elasmobranchii, Sarcopterygii                                                 |
| Invertebrates (non-corals)          |             | All Animalia (Kingdom) EXCEPT: [Chordata (Phylum) and Anthozoa (Class) and Hydrozoa (Class)]  |
| Corals                              | 2 x Class   | Anthozoa, Hydrozoa                                                                            |
| Plants (excluding cacti & orchids)  |             | All Plantae (Kingdom) EXCEPT: [Cactaceae (Family) and Orchidaceae (Family)]                   |
| Cacti                               | Family      | Cactaceae                                                                                     |
| Orchids                             | Family      | Orchidaceae                                                                                   |