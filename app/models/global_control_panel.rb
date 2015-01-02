class GlobalControlPanel
  def self.dates
    datelist = []
    @range.each do  |timedivision|
        datelist << [timedivision[1]['description'],timedivision[1]['enddate']]
    end
    datelist.sort {|x,y| y <=> x }
  end

  def self.setrange
    @range = {}
    gap = 4
    max = 2012 # GlobalTradeSummary.maxdate
    min = GlobalTradeSummary.mindate

    startdate = max
    while startdate >=  min
      enddate = startdate - gap
      enddate = min if enddate < min
      @range[startdate.to_s] = {'enddate' => startdate, 'description' => (enddate >= min ? enddate : min).to_s + "-" + startdate.to_s , 'startdate' => enddate}
      startdate -= gap+1
    end
  end

  def self.range
    @range
  end

  self.setrange

  def initialize(attributes)
      if GroupTerm.groups.include?(attributes[:group])
        @group = attributes[:group]
      else
        raise "Invalid group"
      end
      @date_range = attributes[:date_range]
      @term = attributes[:term]
      @source = attributes[:source]
      @display = attributes[:display]
      @reportertype = attributes[:reportertype]
  end

  def dateendpoints
    GlobalControlPanel.range[@date_range]
  end

  def group
    @group
  end

  def groups
    ["Mammals","Birds","Fish","Reptiles","Amphibians","Corals","Cacti","Orchids","Invertebrates (non-corals)","Plants (excluding cacti & orchids)"]
  end

  def display
    @display
  end

  def date_range
    @date_range
  end

  def term
    @term
  end
  def term=(t)
    @term  = t
  end


  def source
    if @source != 'All'
      @source
    else
      nil
    end
  end

  def sourcedescription
    if @source != 'All'
      SourceDetails.source_description(@source,@group)
    else
      'All'
    end
  end

  def termdescription
    #term = TermsDetails.find_by_term_code(@term)
    #term.english_term_name.capitalize
    GroupTerm.find(@term).term_description.capitalize
  end

  def displaydescription
    case @display
      when 'Time'
        return 'Trade over Time'
    end
  end

  def reportertype
    @reportertype
  end

  def reporter_type_description
    @reportertype == "I" ? "Importer" : "Exporter"
  end
end