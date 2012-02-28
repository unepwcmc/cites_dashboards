class CitesRegion < ActiveRecord::Base
    set_primary_key :cites_region_code

    has_many    :constituent_territories,
              :class_name => "TradingCountry",
              :foreign_key => "cites_region_code"
end
