class LoadGroupTerms < ActiveRecord::Migration
  def self.up
    down

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Bodies','BOD');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Hair (kg)','HAI');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Horns','HOR');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Ivory carvings','IVC');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Live','LIV');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Musk','MUS');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Skins','SKI');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Skulls','SKU');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Teeth','TEE');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Trophies','TRO');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Mammals' ,'Tusks','TUS');"

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Birds' ,'Bodies','BOD');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Birds' ,'Eggs','EGG');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Birds' ,'Live','LIV');"

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Reptiles' ,'Bodies','BOD');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Reptiles' ,'Carapaces','CAP');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Reptiles' ,'Live','LIV');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Reptiles' ,'Shells','SHE');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Reptiles' ,'Skins','SKI');"

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Amphibians' ,'Bodies','BOD');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Amphibians' ,'Live','LIV');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Amphibians' ,'Meat (kg)','MEA');"

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Fish' ,'Bodies','BOD');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Fish' ,'Eggs (kg)','EGG');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Fish' ,'Egg Live','EGL');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Fish' ,'Live','LIV');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Fish' ,'Meat (kg)','MEA');"

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Invertebrates' ,'Bodies','BOD');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Invertebrates' ,'Live','LIV');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Invertebrates' ,'Meat (kg)','MEA');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Invertebrates' ,'Shells','SHE');"

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Corals' ,'Live','LIV');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Corals' ,'Raw Corals','COR');"

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Bark','BAR');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Carvings','CAR');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Chips','CHP');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Dried Plants','DPL');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Extract','EXT');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Powder','POW');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Roots','ROO');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Live','LIV');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Seeds','SEE');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Stems','STE');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Timber (m3)','TIM');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('All Plants' ,'Wax','WAX');"

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Orchids' ,'Live','LIV');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Orchids' ,'Dried Plants','DPL');"

    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Cacti' ,'Live','LIV');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Cacti' ,'Stems','STE');"
    execute "INSERT INTO group_terms (taxon_group,term_description,term_code) VALUES ('Cacti' ,'Seeds','SEE');"
  end

  def self.down
    GroupTerm.delete_all
  end
end
