# CITES Dashboards

CITES Trade Data Dashboards (http://dashboards.cites.org/national) provide and overview of CITES trade data.

## Setting up:

This is a Rails 2 application that has been updated to run on Ruby 2.2.3 as described here: http://blog.lucascaton.com.br/index.php/2014/02/28/have-a-rails-2-app-you-can-run-it-on-the-newest-ruby/

Gems are installed via bundler. Database is best obtained from a copy, as migrations don't seem reliable. To start the application locally: `bundle exec script/server`

## Steps required to update the CITES Dashboards:
  - obtain a fresh copy of both the Species+ & CITES Trade db and last CITES Dashboards db and install them locally; do not run these scripts on production machines
  - export data from Species+ and CITES Trade db
    * export trade in format ready for global / national details: db/scripts/export_trade.sql
    * export list of taxon concepts with automatic mapping to dashboard taxon groups: db/scripts/export_taxon_concepts.sql
  - import taxon concepts
    * import taxon concepts: import_taxon_concepts.sql
    * VERIFY the automatic mapping by running db/scripts/verify_taxon_groups.sql - in case there are taxa in trade that do not map automatically to CITES dashboards taxon groups, do not proceed until that is resolved by either amending data in Species+ or a workaround in the export_taxon_concepts script. Check with Species team if unsure.
  - import global & national details and aggregate data
    * Use the file 'importing_global.sql' to import the global data
    * Use the file 'importing_national.sql' to import the national data
    * Amend the date ranges in 'getting top species' and 'getting top families' as required (HINT: if the last included year from previous update was e.g. 2013, grep for all occurrences of 2013 in those files to know where changes will be needed). Usually the ranges include 5 years and when adding a new year these may need to be rearranged; please speak with Species team if unsure.
    * Run 'getting top species' (**WARNING: this takes around 8 hours**, best leave running overnight)
    * Run 'getting top families'
    * Amend `maxdate` in `app/models/global_trade_summary.rb` and `app/models/national_trade_summary.rb`
    * Amend the `set_range` method in `app/models/global_control_panel.rb` (in particular the `gap` and `startdate` values) accordingly with the date ranges updated
  - copy the database from localhost to staging and let Species team know it is ready for their verification
  - if all good, replace the production database with the staging database

## About taxon groups

This is the definition of taxon groups:

| Group                               | Taxon rank  | Taxon name                                                                                    |
|------------------------------------ |------------ |---------------------------------------------------------------------------------------------- |
| Mammals                             | Class       | Mammalia                                                                                      |
| Birds                               | Class       | Aves                                                                                          |
| Reptiles                            | Class       | Reptilia, includes: [Chamaeleon(full_name) and Pelophilus(full_name) ]                                                                                    |
| Amphibians                          | Class       | Amphibia                                                                                      |
| Fish                                | 4 x Class   | Actinopteri, Elasmobranchii, Dipneusti, Coelacanthi                                                 |
| Invertebrates (non-corals)          |             | All Animalia (Kingdom) EXCEPT: [Chordata (Phylum) and Anthozoa (Class) and Hydrozoa (Class)]  |
| Corals                              | 2 x Class, Phylum   | Anthozoa(Class), Hydrozoa(Class), Cnidaria(Phylum) AND Class/Order/Family/Genus is blank                                                                           |
| Plants (excluding cacti & orchids)  |             | All Plantae (Kingdom) EXCEPT: [Cactaceae (Family) and Orchidaceae (Family)] OR Family is blank                  |
| Cacti                               | Family      | Cactaceae                                                                                     |
| Orchids                             | Family      | Orchidaceae                                                                                   |
