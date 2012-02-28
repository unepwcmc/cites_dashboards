class SourceDetails < ActiveRecord::Base
  def self.source_description(source_code,group,short=false)
      source = self.find_by_source_code(source_code)
      if source.source_code == 'D'
        if ['Mammals', 'Birds', 'Reptiles', 'Amphibians', 'Fish', 'Inverts', 'Corals'].include?(group)
          return short ? "Captive-bred (D)" : "Captive-bred (App. I, commercial) (D)"
        else
          return short ? "Artificially propagated (D)": "Artificially propagated (App. I, commercial) (D)"
        end
      else
        return source.source_english_name + ' (' + source.source_code + ')'
      end
  end

  def self.sources(group)
    sourcearray = []
    sources = SourceDetails.find(:all, :order => 'source_english_name', :conditions => self.conditions(group))
    sources.each {|x|
      sourcename = ''
      if x.source_code == 'D'
        if ['Mammals', 'Birds', 'Reptiles', 'Amphibians', 'Fish', 'Invertebrates (non-corals)', 'Corals'].include?(group)
          sourcename = "Captive-bred (App. I, commercial)"
        else
          sourcename = "Artificially propagated (App. I, commercial)"
        end
      else
        sourcename = x.source_english_name
      end
      sourcearray << ['(' + x.source_code + ') ' + sourcename,x.source_code]
    }
    sourcearray
  end

  def self.conditions(group)
    if ['Mammals', 'Birds', 'Reptiles', 'Amphibians', 'Fish', 'Invertebrates (non-corals)', 'Corals'].include?(group)
      conditions = "source_code in ('W','R','C','D','F','O','U')"
    else
      conditions = "source_code in ('W','A','D','O','U')"
    end
    conditions
  end

end
