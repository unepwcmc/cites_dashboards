-- Global Data
select reporter_type, 
       shipment_year, 
       appendix, 
       shipment_details.cites_taxon_code,
       term_code_1,
       unit_code_1,
       sum(quantity_1), 
       source_code, 
       purpose_code
from shipment_details 
where (purpose_code in ('T','H','P') or purpose_code is null)
  and source_code <> 'I'
  and import_country_code <> export_country_code
  and appendix <> 'N'
  and origin_country_code is null
--and shipment_year between 2006 and 2010
group by reporter_type, 
       shipment_year, 
       appendix,
       shipment_details.cites_taxon_code,
       term_code_1,
       unit_code_1, 
       source_code, 
       purpose_code
order by reporter_type,shipment_year


-- National Data
select reporter_type, 
       shipment_year,
       appendix,
       import_country_code,
       export_country_code,
       origin_country_code,
       shipment_details.cites_taxon_code,
       term_code_1,
       unit_code_1,
       sum(quantity_1), 
       source_code, 
       purpose_code
from shipment_details inner join cites_taxon_codes 
    on shipment_details.cites_taxon_code = cites_taxon_codes.cites_taxon_code
where (purpose_code in ('T','H','P') or purpose_code is null)
  and source_code <> 'I'
  and import_country_code <> export_country_code
  and appendix <> 'N'
  and shipment_year between 2001 and 2008 --This report has to be run for small time periods due to the amount of data
--and shipment_year between 2006 and 2010
group by reporter_type, 
       shipment_year,
       appendix,
       import_country_code,
       export_country_code,
       origin_country_code,
       shipment_details.cites_taxon_code,
       term_code_1,
       unit_code_1, 
       source_code, 
       purpose_code
order by reporter_type,shipment_year