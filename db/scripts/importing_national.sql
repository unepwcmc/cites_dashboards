-- import data
DROP INDEX IF EXISTS index_national_detail_on_taxon_concept_id;
TRUNCATE national_detail;
copy national_detail (
  reporter_type,
  shipment_year,
  appendix,
  import_country_code,
  export_country_code,
  origin_country_code,
  term_code_1,
  unit_code_1,
  quantity_1,
  source_code,
  purpose_code,
  full_name_with_spp,
  full_name,
  genus_name,
  family_name,
  order_name,
  class_name,
  phylum_name,
  kingdom_name,
  taxon_concept_id
) from '/tmp/export_national_1990_jul_2015.csv' delimiters ',' csv;
copy national_detail (
  reporter_type,
  shipment_year,
  appendix,
  import_country_code,
  export_country_code,
  origin_country_code,
  term_code_1,
  unit_code_1,
  quantity_1,
  source_code,
  purpose_code,
  full_name_with_spp,
  full_name,
  genus_name,
  family_name,
  order_name,
  class_name,
  phylum_name,
  kingdom_name,
  taxon_concept_id
) from '/tmp/export_national_1990_2000_jul_2015.csv' delimiters ',' csv;
copy national_detail (
  reporter_type,
  shipment_year,
  appendix,
  import_country_code,
  export_country_code,
  origin_country_code,
  term_code_1,
  unit_code_1,
  quantity_1,
  source_code,
  purpose_code,
  full_name_with_spp,
  full_name,
  genus_name,
  family_name,
  order_name,
  class_name,
  phylum_name,
  kingdom_name,
  taxon_concept_id
) from '/tmp/export_national_2000_2010_jul_2015.csv' delimiters ',' csv;
copy national_detail (
  reporter_type,
  shipment_year,
  appendix,
  import_country_code,
  export_country_code,
  origin_country_code,
  term_code_1,
  unit_code_1,
  quantity_1,
  source_code,
  purpose_code,
  full_name_with_spp,
  full_name,
  genus_name,
  family_name,
  order_name,
  class_name,
  phylum_name,
  kingdom_name,
  taxon_concept_id
) from '/tmp/export_national_2010_jul_2015.csv' delimiters ',' csv;

--apply standardisation sql
--THE FOLLOWING SHOULD BE RUN ON ALL SQLs FOR EC ANALYSIS (EXCEPT CHAPTER 3 SQLS)

--REPTILES

--NEW!
--converts shells to carapaces
update national_detail set term_code_1 = 'CAP' where term_code_1 = 'SHE'
and class_name = 'Reptilia';


--converts flanks to whole skins for crocodilians
update national_detail set quantity_1 = quantity_1/2 where order_name = 'Crocodylia'
and term_code_1 = 'SKI' and unit_code_1 = 'SID';

update national_detail set unit_code_1 = null where order_name = 'Crocodylia'
and term_code_1 = 'SKI' and unit_code_1 in ('BSK', 'HRN', 'SID');

--removes reptile skins reported in other units
delete from national_detail where order_name = 'Crocodylia'
and term_code_1 = 'SKI' and unit_code_1 is not null;

--AMPHS: converts frogs legs to meat
update national_detail set term_code_1 = 'MEA' where term_code_1 = 'LEG' 
and class_name = 'Amphibia';

--PLANTS
--this updates roots to live for Galanthus
update national_detail set term_code_1 = 'LIV' where term_code_1 = 'ROO'
and split_part(full_name, ' ', 1) = 'Galanthus';

--this updates roots to live for Cyclamen spp.
update national_detail set term_code_1 = 'LIV' where term_code_1 = 'ROO'
and split_part(full_name, ' ', 1) = 'Cyclamen';

--this updates roots to live for Sternbergia spp.
update national_detail set term_code_1 = 'LIV' where term_code_1 = 'ROO'
and split_part(full_name, ' ', 1) = 'Sternbergia';

--this combines derivatives, extract and powder together for Aloes
update national_detail set term_code_1 = 'EXT' where term_code_1 = 'POW'
and split_part(full_name, ' ', 1) = 'Aloe';
update national_detail set term_code_1 = 'EXT' where term_code_1 = 'DER'
and split_part(full_name, ' ', 1) = 'Aloe';

--this combines dried plants and roots for Bletilla striata
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'ROO'
and full_name = 'Bletilla striata';

--this combines terms for Cyatheaceae
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'BAR'
and family_name = 'Cyatheaceae';
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'STE'
and family_name = 'Cyatheaceae';
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'CAR'
and family_name = 'Cyatheaceae';
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'FIB'
and family_name = 'Cyatheaceae';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW'
and family_name = 'Cyatheaceae';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG'
and family_name = 'Cyatheaceae';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP'
and family_name = 'Cyatheaceae';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'PLY'
and family_name = 'Cyatheaceae';

--this combines terms for Cibotium barometz 
update national_detail set term_code_1 = 'ROO' where term_code_1 = 'DPL'
and full_name = 'Cibotium barometz';

--this combines terms for Dicksonia
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'BAR'
and split_part(full_name, ' ', 1) = 'Dicksonia';
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'FPT'
and split_part(full_name, ' ', 1) = 'Dicksonia';
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'CAR'
and split_part(full_name, ' ', 1) = 'Dicksonia';
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'FIB'
and split_part(full_name, ' ', 1) = 'Dicksonia';
update national_detail set term_code_1 = 'DPL' where term_code_1 = 'STE'
and split_part(full_name, ' ', 1) = 'Dicksonia';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW'
and split_part(full_name, ' ', 1) = 'Dicksonia';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG'
and split_part(full_name, ' ', 1) = 'Dicksonia';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP'
and split_part(full_name, ' ', 1) = 'Dicksonia';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'PLY'
and split_part(full_name, ' ', 1) = 'Dicksonia';

--General
update national_detail set quantity_1 = quantity_1/2 where unit_code_1 = 'SID';
update national_detail set quantity_1 = quantity_1*2 where unit_code_1 = 'PAI';
update national_detail set term_code_1 = 'SKP' where term_code_1 = 'SKI' and unit_code_1 = 'BAK';
update national_detail set unit_code_1 = null where unit_code_1 = 'BSK';
update national_detail set unit_code_1 = null where unit_code_1 = 'HRN';
update national_detail set unit_code_1 = null where unit_code_1 = 'SID';
update national_detail set unit_code_1 = null where unit_code_1 = '   ';
update national_detail set unit_code_1 = null where unit_code_1 = 'PAI';
update national_detail set unit_code_1 = null where unit_code_1 = 'ITE';
update national_detail set unit_code_1 = null where unit_code_1 = 'BAK';

--These aren't needed for dashboard as we are excluding small leather products (LPS)
--update national_detail set term_code_1 = 'LPS' where term_code_1 = 'BEL';
--update national_detail set term_code_1 = 'LPS' where term_code_1 = 'HAN';
--update national_detail set term_code_1 = 'LPS' where term_code_1 = 'LEA';
--update national_detail set term_code_1 = 'LPS' where term_code_1 = 'LPL';
--update national_detail set term_code_1 = 'LPS' where term_code_1 = 'SHO';
--update national_detail set term_code_1 = 'LPS' where term_code_1 = 'SKO';
--update national_detail set term_code_1 = 'LPS' where term_code_1 = 'WAL';
--update national_detail set term_code_1 = 'LPS' where term_code_1 = 'WAT';

--update national_detail set term_code_1 = 'UNS' where term_code_1 = 'OTH';
--update national_detail set term_code_1 = 'SKP' where term_code_1 = 'SKS';
--update national_detail set term_code_1 = 'CAR' where term_code_1 = 'FUR';
--update national_detail set unit_code_1 = 'SHP' where unit_code_1 = 'BOX';
--update national_detail set unit_code_1 = 'SHP' where unit_code_1 = 'CRT';
--update national_detail set unit_code_1 = 'SHP' where unit_code_1 = 'BAG';
--update national_detail set unit_code_1 = 'FLA' where unit_code_1 = 'BOT';
--update national_detail set unit_code_1 = 'FLA' where unit_code_1 = 'CAN';
--update national_detail set unit_code_1 = null where unit_code_1 = 'SET';
--update national_detail set term_code_1 = 'SPE' where term_code_1 = 'PIE';
--update national_detail set term_code_1 = 'CAR' where term_code_1 = 'TIC';
--update national_detail set term_code_1 = 'SPE' where term_code_1 = 'TIS';
--update national_detail set unit_code_1 = null where unit_code_1 = 'ITE';
--update national_detail set unit_code_1 = null where unit_code_1 = 'INC';

--Converts the unit "pieces" to null, as it is implied that it's pieces for corals, for example. 
update national_detail set unit_code_1 = null where unit_code_1 = 'PCS';

--converts grams to kilograms
update national_detail set quantity_1 = quantity_1/1000 where unit_code_1 = 'GRM';
update national_detail set unit_code_1 = 'KIL' where unit_code_1 = 'GRM';

--converts ml to litres
update national_detail set quantity_1 = quantity_1/1000 where unit_code_1 = 'MLT';
update national_detail set unit_code_1 = 'LTR' where unit_code_1 = 'MLT';

--converts milligrams to kilograms
update national_detail set quantity_1 = quantity_1/1000000 where unit_code_1 = 'MGM';
update national_detail set unit_code_1 = 'KIL' where unit_code_1 = 'MGM';

--more conversions...
update national_detail set quantity_1 = quantity_1/1000000 where unit_code_1 = 'CCM';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'CCM';

update national_detail set quantity_1 = quantity_1/1000 where unit_code_1 = 'CTM';
update national_detail set unit_code_1 = 'MTR' where unit_code_1 = 'CTM';
update national_detail set quantity_1 = quantity_1/10000 where unit_code_1 = 'SQC';
update national_detail set unit_code_1 = 'SQM' where unit_code_1 = 'SQC';
update national_detail set quantity_1 = quantity_1*0.0929 where unit_code_1 = 'SQF';
update national_detail set unit_code_1 = 'SQM' where unit_code_1 = 'SQF';
update national_detail set quantity_1 = quantity_1/100 where unit_code_1 = 'SQD';
update national_detail set unit_code_1 = 'SQM' where unit_code_1 = 'SQD';


--TIMBER the following combines like timber terms and converts kg of timber to m3 where
--a conversion factor is available
--this is for Carnegiea gigantea 4162.2
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Carnegiea gigantea';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Carnegiea gigantea';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'STE' and full_name = 'Carnegiea gigantea';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'PLY' and full_name = 'Carnegiea gigantea';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Carnegiea gigantea';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Carnegiea gigantea';

--this is for Aquilaria malaccensis
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Aquilaria malaccensis';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Aquilaria malaccensis';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Aquilaria malaccensis';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Aquilaria malaccensis';
update national_detail set term_code_1 = 'CHP' where term_code_1 = 'POW' and full_name = 'Aquilaria malaccensis';

--Pericopsis elata
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Pericopsis elata';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Pericopsis elata';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Pericopsis elata';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Pericopsis elata';
update national_detail set quantity_1 = quantity_1/725 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Pericopsis elata';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Pericopsis elata';

--Cedrela odorata
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Cedrela odorata';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Cedrela odorata';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Cedrela odorata';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Cedrela odorata';
update national_detail set quantity_1 = quantity_1/440 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Cedrela odorata';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Cedrela odorata';

--Guaiacum sanctum
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Guaiacum sanctum';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Guaiacum sanctum';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Guaiacum sanctum';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Guaiacum sanctum';
update national_detail set quantity_1 = quantity_1/1230 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Guaiacum sanctum';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Guaiacum sanctum';

--Guaiacum officinale
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Guaiacum officinale';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Guaiacum officinale';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Guaiacum officinale';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Guaiacum officinale';
update national_detail set quantity_1 = quantity_1/1230 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Guaiacum officinale';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Guaiacum officinale';

--Swietenia macrophylla
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Swietenia macrophylla';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Swietenia macrophylla';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Swietenia macrophylla';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Swietenia macrophylla';
update national_detail set quantity_1 = quantity_1/730 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia macrophylla';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia macrophylla';

--Swietenia humilis
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Swietenia humilis';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Swietenia humilis';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Swietenia humilis';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Swietenia humilis';
update national_detail set quantity_1 = quantity_1/610 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia humilis';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia humilis';

--Swietenia mahagoni
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Swietenia mahagoni';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Swietenia mahagoni';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Swietenia mahagoni';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Swietenia mahagoni';
update national_detail set quantity_1 = quantity_1/750 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia mahagoni';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia mahagoni';

--'Araucaria araucana'
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Araucaria araucana';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Araucaria araucana';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Araucaria araucana';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Araucaria araucana';
update national_detail set quantity_1 = quantity_1/570 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Araucaria araucana';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Araucaria araucana';

--Fitzroya cupressoides
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Fitzroya cupressoides';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Fitzroya cupressoides';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Fitzroya cupressoides';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Fitzroya cupressoides';
update national_detail set quantity_1 = quantity_1/480 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Fitzroya cupressoides';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Fitzroya cupressoides';

--Dalbergia nigra
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Dalbergia nigra';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Dalbergia nigra';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Dalbergia nigra';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Dalbergia nigra';
update national_detail set quantity_1 = quantity_1/970 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Dalbergia nigra';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Dalbergia nigra';

--Abies guatemalensis
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Abies guatemalensis';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Abies guatemalensis';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Abies guatemalensis';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Abies guatemalensis';
update national_detail set quantity_1 = quantity_1/350 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Abies guatemalensis';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Abies guatemalensis';

--Prunus africana
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Prunus africana';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Prunus africana';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Prunus africana';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Prunus africana';
update national_detail set quantity_1 = quantity_1/740 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Prunus africana';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Prunus africana';

--Gonystylus spp. 
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and split_part(full_name, ' ', 1) = 'Gonystylus';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and split_part(full_name, ' ', 1) = 'Gonystylus';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and split_part(full_name, ' ', 1) = 'Gonystylus';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and split_part(full_name, ' ', 1) = 'Gonystylus';
update national_detail set quantity_1 = quantity_1/660 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and split_part(full_name, ' ', 1) = 'Gonystylus';
update national_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and split_part(full_name, ' ', 1) = 'Gonystylus';

--NEW:  Converts logs, sawn wood, timber pieces and veneer to timber for rest of taxa
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP';
update national_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN';

--Deletes timber when the unit is not cubic metres
delete from national_detail where term_code_1 ='TIM' and unit_code_1 is null;
delete from national_detail where term_code_1 ='TIM' and unit_code_1 != 'CUM';


--Italy doesn't report a source for its Appendix-III taxa so this tries to best guess those taxa that are likely to be from wild-sources
--Appendix III taxa (most notably birds) reported by Italy with no source
--update national_detail set source_code = 'W' where source_code is null and import_country_code = 'IT' and appendix ='3' and 
--export_country_code in ('SN', 'ML', 'TZ', 'GN', 'PK', 'UG', 'GH');

--deletes elephant skins
delete from national_detail where term_code_1 ='SKI'
and family_name = 'Elephantidae';

--Combine ivory carvings, carvings, and ivory pieces into "ivory carvings" for elephants
update national_detail set term_code_1 = 'IVC' where term_code_1 = 'IVP' and family_name = 'Elephantidae';
update national_detail set term_code_1 = 'IVC' where term_code_1 = 'CAR' and family_name = 'Elephantidae';

--Combines terms for cacti rainsticks
update national_detail set term_code_1 = 'STE' where term_code_1 = 'CAR' and family_name = 'Cactaceae';
update national_detail set term_code_1 = 'STE' where term_code_1 = 'TIP' and family_name = 'Cactaceae';
update national_detail set term_code_1 = 'STE' where term_code_1 = 'DPL' and family_name = 'Cactaceae';

delete from national_detail where term_code_1 not in
('BAR', 'BOD','CAP', 'CAR', 'CHP', 'EXT', 'DPL','EGG', 'EGL', 'HAI', 'HOR','IVC', 'LIV', 'MEA', 'MUS', 'COR','ROO', 'SEE',
 'SHE', 'SKI', 'SKP', 'SKU','STE', 'TIM', 'TRO', 'VEN','TUS','TEE','WAX', 'POW');

--deleting out terms inappropriate for the calculations for mammals, birds and reptiles
delete from national_detail where term_code_1 in
( 'BAR', 'CAR', 'CHP', 'COR', 'DPL', 'EXT', 'EGL', 'MEA', 'ROO', 'SEE', 'SHE', 'STE', 'TIM', 'VEN', 'WAX', 'POW')
and (class_name = 'Mammalia' OR
class_name = 'Aves' OR
class_name = 'Reptilia');

--MUSK FOR MUSK DEER and CIVITIS
delete from national_detail where term_code_1 = 'MUS' AND NOT
split_part(full_name, ' ', 1) = 'Moschus';

--FROG MEAT, sturgeon meat & STROMBUS GIGAS MEAT
delete from national_detail where term_code_1 = 'MEA' and NOT
(class_name = 'Amphibia' OR
order_name = 'Acipenseriformes' OR
full_name = 'Strombus gigas');

--TUSKS FOR ELEPHANTS, HIPPOS, WALRUS & NARWHAL ONLY
delete from national_detail where term_code_1 = 'TUS' AND NOT
(family_name = 'Elephantidae' OR
family_name = 'Hippopotamidae' OR
full_name = 'Odobenus rosmarus' or
full_name = 'Monodon monoceros');

--Deleted these as we want to include tusks (blank) and tusks (kg)
--delete from national_detail where term_code_1 = 'TUS' and
--cites_taxon_code in (832, 832.1, 501, 501.1, 710.1) and unit_code_1 is not null;
--delete from national_detail where term_code_1 = 'TUS' and
--cites_taxon_code between 750 and 752.2 and unit_code_1 is not null;

--Amend, remove conversion factor to give real number of tusks
--divides no. of tusks by 1.88 to estimate no. of eles
--update national_detail set quantity_1 = quantity_1/1.88 where term_code_1 = 'TUS'
--and cites_taxon_code between 750 and 752.2;

--Amend, don't want to limit teeth
--TEETH FOR HIPPOS (+deletes teeth if not a hippo)
--delete from national_detail where term_code_1 = 'TEE' and
--cites_taxon_code != 832.1;


--Amend, don't want to divide by 12
--divides no. of hippo teeth by 12 to estimate no. of hippos
--update national_detail set quantity_1 = quantity_1/12 where term_code_1 = 'TEE'
--and cites_taxon_code = 832.1 and unit_code_1 is null;

--Amend, larger range for turtles & tortoises
--TURTLE CARAPACES
delete from national_detail where term_code_1 = 'CAP'
and order_name != 'Testudines';

--Amend, delete section on EUPHORBIA WAX
--delete from national_detail where term_code_1 = 'WAX' and
--cites_taxon_code != 5133.5;

--Amend, delete section on Prunus africana
--delete from national_detail where term_code_1 in ('POW', 'BAR')
--and cites_taxon_code not between 7495 and 7495.1;

--------THE FOLLOWING NEEDS ADDITIONAL TERMS ADDED IF WE USE THIS TO LIMIT THE TERMS FOR THE DASHBOARD
--deleting out terms not appropriate for the calculations for birds
delete from national_detail where term_code_1 in ('SKI')
and class_name = 'Aves';

--deleting out terms inappropriate for the calculations for amphibians
delete from national_detail where term_code_1 in ('EGG','EGL')
and class_name = 'Amphibia';

--Amend, delete 'MEA' from here because we want it for sturgeon
--deleting out terms inappropriate for the calculations for fish
delete from national_detail where term_code_1 in ('DER','SKI')
and (class_name = 'Actinopterygii' OR
class_name = 'Sarcopterygii');

--deleting out terms inappropriate for the calculations for inverts
delete from national_detail where term_code_1 in ('DER','EGG')
and phylum_name != 'Chordata';

--summarise data and import
TRUNCATE national_trade_summaries;
insert into national_trade_summaries (shipment_year,appendix,reporter_type,origin_country_code,import_country_code,export_country_code,term_code,unit_code,quantity,source_code,purpose_code,taxon_group,group_term_id)
select shipment_year,appendix,reporter_type,origin_country_code,import_country_code,export_country_code,term_code_1,unit_code_1,sum(quantity_1),source_code,purpose_code, taxon_concepts.taxon_group,group_terms.id
from national_detail
  inner join taxon_concepts on national_detail.taxon_concept_id = taxon_concepts.id
  inner join group_terms on taxon_concepts.taxon_group = group_terms.taxon_group and national_detail.term_code_1 =  group_terms.term_code
  and (national_detail.unit_code_1 = group_terms.unit_code or (national_detail.unit_code_1 is null and group_terms.unit_code is null))
where appendix in ('I','II','III')
group by shipment_year,appendix,origin_country_code,reporter_type,import_country_code,export_country_code,term_code_1,unit_code_1,source_code,purpose_code, taxon_concepts.taxon_group, group_terms.id

CREATE INDEX index_national_detail_on_taxon_concept_id ON national_detail (taxon_concept_id);
--Now run 'getting top species' and 'getting top families'