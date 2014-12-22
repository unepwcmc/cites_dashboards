-- import data
--copy global_detail from '/Documents and Settings/jenniferp/global_with_appendix.csv' delimiters ',' csv;
delete from global_detail;
copy global_detail from 'csvs_dec2014/export_global_dec_2014.csv' delimiters ',' csv;

--apply standardisation sql
--THE FOLLOWING SHOULD BE RUN ON ALL SQLs FOR EC ANALYSIS (EXCEPT CHAPTER 3 SQLS)

--REPTILES

--NEW!
--converts shells to carapaces
update global_detail set term_code_1 = 'CAP' where term_code_1 = 'SHE'
and taxo_data @> '"class_name" => "Reptilia"'::hstore;


--converts flanks to whole skins for crocodilians
update global_detail set quantity_1 = quantity_1/2 where taxo_data @> '"class_name" => "Crocodylia"'::hstore
and term_code_1 = 'SKI' and unit_code_1 = 'SID';

update global_detail set unit_code_1 = null where taxo_data @> '"order_name" => "Crocodylia"'::hstore
and term_code_1 = 'SKI' and unit_code_1 in ('BSK', 'HRN', 'SID');

--removes reptile skins reported in other units
delete from global_detail where taxo_data @> '"order_name" => "Crocodylia"'::hstore
and term_code_1 = 'SKI' and unit_code_1 is not null;

--AMPHS: converts frogs legs to meat
update global_detail set term_code_1 = 'MEA' where term_code_1 = 'LEG' 
and taxo_data @> '"class_name" => "Amphibia"'::hstore;

--PLANTS
--this updates roots to live for Galanthus
update global_detail set term_code_1 = 'LIV' where term_code_1 = 'ROO'
and split_part(full_name, ' ', 1) = "Galanthus";

--this updates roots to live for Cyclamen spp.
update global_detail set term_code_1 = 'LIV' where term_code_1 = 'ROO'
and split_part(full_name, ' ', 1) = "Cyclamen";

--this updates roots to live for Sternbergia spp.
update global_detail set term_code_1 = 'LIV' where term_code_1 = 'ROO'
and split_part(full_name, ' ', 1) = "Sternbergia";

--this combines derivatives, extract and powder together for Aloes
update global_detail set term_code_1 = 'EXT' where term_code_1 = 'POW'
and split_part(full_name, ' ', 1) = "Aloe";
update global_detail set term_code_1 = 'EXT' where term_code_1 = 'DER'
and split_part(full_name, ' ', 1) = "Aloe";

--this combines dried plants and roots for Bletilla striata
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'ROO'
and full_name = 'Bletilla striata';

--this combines terms for Cyatheaceae
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'BAR'
and taxo_data @> '"family_name" => "Cyatheaceae"'::hstore;
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'STE'
and taxo_data @> '"family_name" => "Cyatheaceae"'::hstore;
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'CAR'
and taxo_data @> '"family_name" => "Cyatheaceae"'::hstore;
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'FIB'
and taxo_data @> '"family_name" => "Cyatheaceae"'::hstore;
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW'
and taxo_data @> '"family_name" => "Cyatheaceae"'::hstore;
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG'
and taxo_data @> '"family_name" => "Cyatheaceae"'::hstore;
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP'
and taxo_data @> '"family_name" => "Cyatheaceae"'::hstore;
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'PLY'
and taxo_data @> '"family_name" => "Cyatheaceae"'::hstore;

--this combines terms for Cibotium barometz 
update global_detail set term_code_1 = 'ROO' where term_code_1 = 'DPL'
and full_name = 'Cibotium barometz';

--this combines terms for Dicksonia
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'BAR'
and split_part(full_name, ' ', 1) = "Dicksonia";
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'FPT'
and split_part(full_name, ' ', 1) = "Dicksonia";
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'CAR'
and split_part(full_name, ' ', 1) = "Dicksonia";
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'FIB'
and split_part(full_name, ' ', 1) = "Dicksonia";
update global_detail set term_code_1 = 'DPL' where term_code_1 = 'STE'
and split_part(full_name, ' ', 1) = "Dicksonia";
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW'
and split_part(full_name, ' ', 1) = "Dicksonia";
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG'
and split_part(full_name, ' ', 1) = "Dicksonia";
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP'
and split_part(full_name, ' ', 1) = "Dicksonia";
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'PLY'
and split_part(full_name, ' ', 1) = "Dicksonia";

--General
update global_detail set quantity_1 = quantity_1/2 where unit_code_1 = 'SID';
update global_detail set quantity_1 = quantity_1*2 where unit_code_1 = 'PAI';
update global_detail set term_code_1 = 'SKP' where term_code_1 = 'SKI' and unit_code_1 = 'BAK';
update global_detail set unit_code_1 = null where unit_code_1 = 'BSK';
update global_detail set unit_code_1 = null where unit_code_1 = 'HRN';
update global_detail set unit_code_1 = null where unit_code_1 = 'SID';
update global_detail set unit_code_1 = null where unit_code_1 = '   ';
update global_detail set unit_code_1 = null where unit_code_1 = 'PAI';
update global_detail set unit_code_1 = null where unit_code_1 = 'ITE';
update global_detail set unit_code_1 = null where unit_code_1 = 'BAK';

--These aren't needed for dashboard as we are excluding small leather products (LPS)
--update global_detail set term_code_1 = 'LPS' where term_code_1 = 'BEL';
--update global_detail set term_code_1 = 'LPS' where term_code_1 = 'HAN';
--update global_detail set term_code_1 = 'LPS' where term_code_1 = 'LEA';
--update global_detail set term_code_1 = 'LPS' where term_code_1 = 'LPL';
--update global_detail set term_code_1 = 'LPS' where term_code_1 = 'SHO';
--update global_detail set term_code_1 = 'LPS' where term_code_1 = 'SKO';
--update global_detail set term_code_1 = 'LPS' where term_code_1 = 'WAL';
--update global_detail set term_code_1 = 'LPS' where term_code_1 = 'WAT';

--update global_detail set term_code_1 = 'UNS' where term_code_1 = 'OTH';
--update global_detail set term_code_1 = 'SKP' where term_code_1 = 'SKS';
--update global_detail set term_code_1 = 'CAR' where term_code_1 = 'FUR';
--update global_detail set unit_code_1 = 'SHP' where unit_code_1 = 'BOX';
--update global_detail set unit_code_1 = 'SHP' where unit_code_1 = 'CRT';
--update global_detail set unit_code_1 = 'SHP' where unit_code_1 = 'BAG';
--update global_detail set unit_code_1 = 'FLA' where unit_code_1 = 'BOT';
--update global_detail set unit_code_1 = 'FLA' where unit_code_1 = 'CAN';
--update global_detail set unit_code_1 = null where unit_code_1 = 'SET';
--update global_detail set term_code_1 = 'SPE' where term_code_1 = 'PIE';
--update global_detail set term_code_1 = 'CAR' where term_code_1 = 'TIC';
--update global_detail set term_code_1 = 'SPE' where term_code_1 = 'TIS';
--update global_detail set unit_code_1 = null where unit_code_1 = 'ITE';
--update global_detail set unit_code_1 = null where unit_code_1 = 'INC';

--Converts the unit "pieces" to null, as it is implied that it's pieces for corals, for example. 
update global_detail set unit_code_1 = null where unit_code_1 = 'PCS';

--converts grams to kilograms
update global_detail set quantity_1 = quantity_1/1000 where unit_code_1 = 'GRM';
update global_detail set unit_code_1 = 'KIL' where unit_code_1 = 'GRM';

--converts ml to litres
update global_detail set quantity_1 = quantity_1/1000 where unit_code_1 = 'MLT';
update global_detail set unit_code_1 = 'LTR' where unit_code_1 = 'MLT';

--converts milligrams to kilograms
update global_detail set quantity_1 = quantity_1/1000000 where unit_code_1 = 'MGM';
update global_detail set unit_code_1 = 'KIL' where unit_code_1 = 'MGM';

--more conversions...
update global_detail set quantity_1 = quantity_1/1000000 where unit_code_1 = 'CCM';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'CCM';

update global_detail set quantity_1 = quantity_1/1000 where unit_code_1 = 'CTM';
update global_detail set unit_code_1 = 'MTR' where unit_code_1 = 'CTM';
update global_detail set quantity_1 = quantity_1/10000 where unit_code_1 = 'SQC';
update global_detail set unit_code_1 = 'SQM' where unit_code_1 = 'SQC';
update global_detail set quantity_1 = quantity_1*0.0929 where unit_code_1 = 'SQF';
update global_detail set unit_code_1 = 'SQM' where unit_code_1 = 'SQF';
update global_detail set quantity_1 = quantity_1/100 where unit_code_1 = 'SQD';
update global_detail set unit_code_1 = 'SQM' where unit_code_1 = 'SQD';


--TIMBER the following combines like timber terms and converts kg of timber to m3 where
--a conversion factor is available
--this is for Carnegiea gigantea 4162.2
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Carnegiea gigantea';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Carnegiea gigantea';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'STE' and full_name = 'Carnegiea gigantea';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'PLY' and full_name = 'Carnegiea gigantea';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Carnegiea gigantea';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Carnegiea gigantea';

--this is for Aquilaria malaccensis
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Aquilaria malaccensis';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Aquilaria malaccensis';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Aquilaria malaccensis';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Aquilaria malaccensis';
update global_detail set term_code_1 = 'CHP' where term_code_1 = 'POW' and full_name = 'Aquilaria malaccensis';

--Pericopsis elata
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Pericopsis elata';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Pericopsis elata';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Pericopsis elata';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Pericopsis elata';
update global_detail set quantity_1 = quantity_1/725 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Pericopsis elata';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Pericopsis elata';

--Cedrela odorata
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Cedrela odorata';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Cedrela odorata';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Cedrela odorata';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Cedrela odorata';
update global_detail set quantity_1 = quantity_1/440 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Cedrela odorata';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Cedrela odorata';

--Guaiacum sanctum
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Guaiacum sanctum';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Guaiacum sanctum';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Guaiacum sanctum';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Guaiacum sanctum';
update global_detail set quantity_1 = quantity_1/1230 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Guaiacum sanctum';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Guaiacum sanctum';

--Guaiacum officinale
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Guaiacum officinale';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Guaiacum officinale';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Guaiacum officinale';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Guaiacum officinale';
update global_detail set quantity_1 = quantity_1/1230 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Guaiacum officinale';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Guaiacum officinale';

--Swietenia macrophylla
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Swietenia macrophylla';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Swietenia macrophylla';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Swietenia macrophylla';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Swietenia macrophylla';
update global_detail set quantity_1 = quantity_1/730 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia macrophylla';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia macrophylla';

--Swietenia humilis
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Swietenia humilis';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Swietenia humilis';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Swietenia humilis';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Swietenia humilis';
update global_detail set quantity_1 = quantity_1/610 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia humilis';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia humilis';

--Swietenia mahagoni
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Swietenia mahagoni';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Swietenia mahagoni';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Swietenia mahagoni';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Swietenia mahagoni';
update global_detail set quantity_1 = quantity_1/750 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia mahagoni';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Swietenia mahagoni';

--'Araucaria araucana'
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Araucaria araucana';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Araucaria araucana';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Araucaria araucana';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Araucaria araucana';
update global_detail set quantity_1 = quantity_1/570 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Araucaria araucana';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Araucaria araucana';

--Fitzroya cupressoides
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Fitzroya cupressoides';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Fitzroya cupressoides';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Fitzroya cupressoides';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Fitzroya cupressoides';
update global_detail set quantity_1 = quantity_1/480 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Fitzroya cupressoides';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Fitzroya cupressoides';

--Dalbergia nigra
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Fitzroya cupressoides';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Fitzroya cupressoides';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Fitzroya cupressoides';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Fitzroya cupressoides';
update global_detail set quantity_1 = quantity_1/970 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Fitzroya cupressoides';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Fitzroya cupressoides';

--Abies guatemalensis
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Abies guatemalensis';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Abies guatemalensis';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Abies guatemalensis';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Abies guatemalensis';
update global_detail set quantity_1 = quantity_1/350 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Abies guatemalensis';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Abies guatemalensis';

--Prunus africana
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and full_name = 'Prunus africana';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and full_name = 'Prunus africana';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and full_name = 'Prunus africana';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and full_name = 'Prunus africana';
update global_detail set quantity_1 = quantity_1/740 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Prunus africana';
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and full_name = 'Prunus africana';

--Gonystylus spp. 
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG' and split_part(full_name, ' ', 1) = "Gonystylus";
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW' and split_part(full_name, ' ', 1) = "Gonystylus";
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP' and split_part(full_name, ' ', 1) = "Gonystylus";
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN' and split_part(full_name, ' ', 1) = "Gonystylus";
update global_detail set quantity_1 = quantity_1/660 where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and split_part(full_name, ' ', 1) = "Gonystylus";
update global_detail set unit_code_1 = 'CUM' where unit_code_1 = 'KIL' and term_code_1 = 'TIM'
and split_part(full_name, ' ', 1) = "Gonystylus";

--NEW:  Converts logs, sawn wood, timber pieces and veneer to timber for rest of taxa
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'LOG';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'SAW';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'TIP';
update global_detail set term_code_1 = 'TIM' where term_code_1 = 'VEN';

--Deletes timber when the unit is not cubic metres
delete from global_detail where term_code_1 ='TIM' and unit_code_1 is null;
delete from global_detail where term_code_1 ='TIM' and unit_code_1 != 'CUM';


--Italy doesn't report a source for its Appendix-III taxa so this tries to best guess those taxa that are likely to be from wild-sources
--Appendix III taxa (most notably birds) reported by Italy with no source
--update global_detail set source_code = 'W' where source_code is null and import_country_code = 'IT' and appendix ='3' and 
--export_country_code in ('SN', 'ML', 'TZ', 'GN', 'PK', 'UG', 'GH');

--deletes elephant skins
delete from global_detail where term_code_1 ='SKI'
and cites_taxon_code between 750 and 752.2;

--Combine ivory carvings, carvings, and ivory pieces into "ivory carvings" for elephants
update global_detail set term_code_1 = 'IVC' where term_code_1 = 'IVP' and taxo_data @> '"family_name" => "Hippopotamidae"';
update global_detail set term_code_1 = 'IVC' where term_code_1 = 'CAR' and taxo_data @> '"family_name" => "Hippopotamidae"';

--Combines terms for cacti rainsticks
update global_detail set term_code_1 = 'STE' where term_code_1 = 'CAR' and taxo_data @> '"family_name" => "Cactaceae"';
update global_detail set term_code_1 = 'STE' where term_code_1 = 'TIP' and taxo_data @> '"family_name" => "Cactaceae"';
update global_detail set term_code_1 = 'STE' where term_code_1 = 'DPL' and taxo_data @> '"family_name" => "Cactaceae"';

delete from global_detail where term_code_1 not in
('BAR', 'BOD','CAP', 'CAR', 'CHP', 'EXT', 'DPL','EGG', 'EGL', 'HAI', 'HOR','IVC', 'LIV', 'MEA', 'MUS', 'COR','ROO', 'SEE',
 'SHE', 'SKI', 'SKP', 'SKU','STE', 'TIM', 'TRO', 'VEN','TUS','TEE','WAX', 'POW');

--deleting out terms inappropriate for the calculations for mammals, birds and reptiles
delete from global_detail where term_code_1 in
( 'BAR', 'CAR', 'CHP', 'COR', 'DPL', 'EXT', 'EGL', 'MEA', 'ROO', 'SEE', 'SHE', 'STE', 'TIM', 'VEN', 'WAX', 'POW')
and (taxo_data @> '"class_name" => "Mammalia"'::hstore OR
taxo_data @> '"class_name" => "Aves"'::hstore OR
taxo_data @> '"class_name" => "Reptilia"'::hstore);

--MUSK FOR MUSK DEER and CIVITIS
delete from global_detail where term_code_1 = 'MUS' AND NOT
split_part(full_name, ' ', 1) = "Moschus";

--FROG MEAT, sturgeon meat & STROMBUS GIGAS MEAT
delete from global_detail where term_code_1 = 'MEA' and NOT
(taxo_data @> '"class_name" => "Amphibia"'::hstore OR
taxo_data @> '"order_name" => "Acipenseriformes"'::hstore OR
full_name = 'Strombus gigas');

--TUSKS FOR ELEPHANTS, HIPPOS, WALRUS & NARWHAL ONLY
delete from global_detail where term_code_1 = 'TUS' AND NOT
(taxo_data @> '"family_name" => "Elephantidae"'::hstore OR
taxo_data @> '"family_name" => "Hippopotamidae"'::hstore OR
full_name = 'Odobenus rosmarus' or
full_name = 'Monodon monoceros');

--Deleted these as we want to include tusks (blank) and tusks (kg)
--delete from global_detail where term_code_1 = 'TUS' and
--cites_taxon_code in (832, 832.1, 501, 501.1, 710.1) and unit_code_1 is not null;
--delete from global_detail where term_code_1 = 'TUS' and
--cites_taxon_code between 750 and 752.2 and unit_code_1 is not null;

--Amend, remove conversion factor to give real number of tusks
--divides no. of tusks by 1.88 to estimate no. of eles
--update global_detail set quantity_1 = quantity_1/1.88 where term_code_1 = 'TUS'
--and cites_taxon_code between 750 and 752.2;

--Amend, don't want to limit teeth
--TEETH FOR HIPPOS (+deletes teeth if not a hippo)
--delete from global_detail where term_code_1 = 'TEE' and
--cites_taxon_code != 832.1;


--Amend, don't want to divide by 12
--divides no. of hippo teeth by 12 to estimate no. of hippos
--update global_detail set quantity_1 = quantity_1/12 where term_code_1 = 'TEE'
--and cites_taxon_code = 832.1 and unit_code_1 is null;

--Amend, larger range for turtles & tortoises
--TURTLE CARAPACES
delete from global_detail where term_code_1 = 'CAP' and NOT
taxo_data @> '"order_name" => "Testudines"'::hstore;

--Amend, delete section on EUPHORBIA WAX
--delete from global_detail where term_code_1 = 'WAX' and
--cites_taxon_code != 5133.5;

--Amend, delete section on Prunus africana
--delete from global_detail where term_code_1 in ('POW', 'BAR')
--and cites_taxon_code not between 7495 and 7495.1;

--------THE FOLLOWING NEEDS ADDITIONAL TERMS ADDED IF WE USE THIS TO LIMIT THE TERMS FOR THE DASHBOARD
--deleting out terms not appropriate for the calculations for birds
delete from global_detail where term_code_1 in ('SKI')
and NOT taxo_data @> '"class_name" => "Aves"'::hstore;

--deleting out terms inappropriate for the calculations for amphibians
delete from global_detail where term_code_1 in ('EGG','EGL')
and taxo_data @> '"class_name" => "Amphibia"'::hstore;

--Amend, delete 'MEA' from here because we want it for sturgeon
--deleting out terms inappropriate for the calculations for fish
delete from global_detail where term_code_1 in ('DER','SKI')
and (taxo_data @> '"class_name" => "Actinopterygii"'::hstore OR
taxo_data @> '"class_name" => "Sarcopterygii"'::hstore);

--deleting out terms inappropriate for the calculations for inverts
delete from global_detail where term_code_1 in ('DER','EGG')
and NOT taxo_data @> '"phylum_name" => "Chordata"'::hstore;

--set appendix
update global_detail set appendix = 'I' where appendix = '1';
update global_detail set appendix = 'II' where appendix = '2';
update global_detail set appendix = 'III' where appendix = '3';
update global_detail set appendix = 'IV' where appendix = '4';
--summarise data and import 
delete from global_trade_summaries;

insert into global_trade_summaries (shipment_year,reporter_type,appendix,term_code,unit_code,quantity,source_code,purpose_code,taxon_group )
select shipment_year,reporter_type,appendix,term_code_1,unit_code_1,sum(quantity_1),source_code,purpose_code, new_taxon_code.taxon_group 
from global_detail 
  inner join new_taxon_code on global_detail.taxon_concept_id = new_taxon_code.taxon_concepts_id
  inner join group_terms on 
    new_taxon_code.taxon_group = group_terms.taxon_group and global_detail.term_code_1 =  group_terms.term_code 
    and (global_detail.unit_code_1 = group_terms.unit_code or (global_detail.unit_code_1 is null and group_terms.unit_code is null))
where appendix in ('I','II','III')
group by shipment_year,appendix,reporter_type,term_code_1,unit_code_1,source_code,purpose_code, new_taxon_code.taxon_group

--export
select * from global_trade_summaries
