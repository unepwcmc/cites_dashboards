require "enumerator"

class SpeciesDistribution < ActiveRecord::Base

  def self.GetDistribution(group,iso_code)
    #I need a list of each level and to be able to drill down the levels
    # What I want is a nested hash so I'm going to have to start at the bottom and get the data back then add it into the hash
    #order, family, genus, species
    result = []
    phylumarray = []


    phylumarray = self.find_by_sql ["SELECT DISTINCT species_distributions.phylum_name,phylum_listing_order FROM species_distributions LEFT OUTER JOIN phylum_orders on species_distributions.phylum_name = phylum_orders.phylum_name  WHERE taxon_group = ? and country = ? ORDER BY phylum_listing_order",group, iso_code ]
    phylumarray.each { |p|
      classarray = []
      classhash = {}
      classarray = self.find_by_sql ["SELECT DISTINCT class_name FROM species_distributions WHERE taxon_group = ? and country = ? and phylum_name = ?",group, iso_code, p.phylum_name ]
      classarray.each { |c|
        orderarray = []
        orderhash = {}
        orderarray = self.find_by_sql ["SELECT DISTINCT order_name FROM species_distributions WHERE taxon_group = ? and country = ? and class_name = ?",group, iso_code, c.class_name ]
        orderarray.each { |order|
          familyarray = []
          familyarray = self.find_by_sql ["SELECT DISTINCT family_name FROM species_distributions WHERE taxon_group = ? and country = ? and order_name = ?",group,iso_code, order.order_name ]
          familyhash = {}
          familyarray.each { |family|
            speciesarray = []
            speciesarray = self.find_by_sql ["SELECT DISTINCT genus_name, species_name, species_subname, species_author FROM species_distributions WHERE taxon_group = ? and country = ? and order_name = ? and family_name = ?  ORDER BY genus_name, species_name, species_subname",group,iso_code, order.order_name, family.family_name ]
            familyhash[family.family_name] = speciesarray  #sorted by the query
          }
          orderhash[order.order_name] = familyhash.sort
        }
        classhash[c.class_name] = orderhash.sort
      }
      result << [p.phylum_name,  classhash.sort]
    }
    result
  end

end
