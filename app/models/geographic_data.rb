class GeographicData
  GeographicOption = Struct.new(:id, :name)

  class GeographicType
    attr_reader :type_name, :options
    def initialize(name)
      @type_name = name
      @options = []
    end
    def <<(option)
      @options << option
    end
  end

  OPTIONS = []

  regions = CitesRegion.find(:all, :order => "cites_region_name")
  regions.each { |r|
    type = GeographicType.new(r.cites_region_name)

    r.constituent_territories.sort_by{|c| c.name}.each { |c|
      unless  c.exclude_from_selection == true
        type << GeographicOption.new(c.iso_country_code,c.name)
      end
      }
    OPTIONS << type
  }
end