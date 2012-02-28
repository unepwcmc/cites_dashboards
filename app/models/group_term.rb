class GroupTerm < ActiveRecord::Base
    def self.term_description(term)
      termdetail = self.find(term)
      if termdetail.unit_code == nil
        termdetail.term_description.capitalize + " (number of)"
      else
        termdetail.term_description.capitalize
      end
  end

  def self.term_description_short(term)
    self.find(term).term_description
  end  

  def self.term_axis_description(term)
      if termdetail.unit_code == nil
        "Number of " + termdetail.term_description.capitalize
      else
        termdetail.term_description.capitalize
      end
  end
    
  def self.terms
    terms = {}
    groups = self.groups
    groups.each { |g|
      terms[g] = self.find(:all, :select => 'id, term_description',:conditions => "taxon_group = \'" + g + "\'").map {|x| [x.term_description,x.id]}.sort
    }
    terms
    end

  def self.groups
    #(self.find_by_sql ["SELECT DISTINCT taxon_group FROM group_terms"]).map {|x| x.taxon_group}  # This works, but KM wants them in a specific order
    ['Mammals', 'Birds', 'Reptiles', 'Amphibians', 'Fish', 'Invertebrates (non-corals)', 'Corals','Orchids','Cacti','Plants (excluding cacti & orchids)']
  end

  def self.default(group)
    self.find_by_taxon_group(group, :conditions => "term_code = 'LIV' and unit_code is null").id
  end
end
