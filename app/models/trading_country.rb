class TradingCountry < ActiveRecord::Base
  attr_reader :entry_date 

  set_primary_key :iso_country_code

  belongs_to  :territory,
              :class_name => "TradingCountry",
              :foreign_key => "dependency_of"

  belongs_to  :cites_region,
              :class_name => "CitesRegion",
              :foreign_key => "cites_region_code"

  has_many    :dependent_territories,
              :class_name => "TradingCountry",
              :foreign_key => "dependency_of"
end
