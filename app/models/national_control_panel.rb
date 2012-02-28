class NationalControlPanel < GlobalControlPanel
  def initialize(attributes)
      super(attributes)
      if attributes[:country].to_s.length == 2
        @country = attributes[:country]
      else
        raise "Invalid country"
      end
  end

  self.setrange

  def country
    @country
  end

  def countrydescription
    TradingCountry.find_by_iso_country_code(@country).name
  end

  def displaydescription
    case @display
      when 'Partners'
        return 'Top Trading Partners'
    end
  end
end