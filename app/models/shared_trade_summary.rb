class SharedTradeSummary
  def self.trade_by_source(group, reporter_type, term, start_year, end_year,country)
    if country == nil
     records = GlobalTradeSummary.sum(:quantity,:group=>'source_code', :order => 'source_code', :conditions => ["taxon_group = ? and reporter_type = ?  and group_term_id = ?  and shipment_year between ? and ? and appendix <> 'III' and " + SourceDetails.conditions(group),
                                                              group,reporter_type,term,start_year,end_year])
    else
     records = NationalTradeSummary.sum(:quantity,:group=>'source_code', :order => 'source_code', :conditions => ["taxon_group = ? and reporter_type = ?  and group_term_id = ?  and shipment_year between ? and ? and " + (reporter_type == 'I' ? 'import_country_code' : 'export_country_code') + " = ?  and appendix <> 'III' and origin_country_code is null and " + SourceDetails.conditions(group),
                                              group,reporter_type,term,start_year,end_year,country])
    end
    sum = records.values.inject{|sum,value| sum + value}

    quantityarray = []
    descriptionarray = []
    codearray = []
    records.each { |x|
      quantityarray << x[1]
      descriptionarray << SourceDetails.source_description(x[0],group,true) + ': ' + "%.1f" % (x[1]/sum*100)  + '%'
      codearray << x[0]
    }
    [quantityarray,descriptionarray,codearray]
  end

  def self.trade_by_year_by_source(group, reporter_type, term, start_year, end_year,country)
  # mattetti googlechart bar chart requires data in format [[year1source1, year2source1],[year1source2, year2source2]]
  # need to make sure that years/groups with no entry result in a nil entry in the array.

  # not possible to do multiple group by - https://rails.lighthouseapp.com/projects/8994/tickets/497-activerecord-calculate-broken-for-multiple-fields-in-group-option.
  # so can't do:
  # records = self.sum(:quantity,:group=>'shipment_year, source_code')
  # so need to do it in two goes

  results = {}
  data = {}
  time = []
  dataarray = []
  sources = {}
  sources = SourceDetails.find(:all, :order => 'source_code', :conditions =>  {:source_code => self.trade_by_source(group, reporter_type, term, start_year, end_year,country)[2]})
  
  sourcenames = []
  records = {}
  yearlytotals = {}
  year =  start_year.to_i

  while year <= end_year.to_i
     if country == nil
      records = GlobalTradeSummary.sum(:quantity,:group=>'source_code', :conditions => ["taxon_group = ? and reporter_type = ?  and group_term_id = ?  and shipment_year = ?  and appendix <> 'III' and " + SourceDetails.conditions(group),
                                                               group,reporter_type,term,year.to_s])
     else
      records = NationalTradeSummary.sum(:quantity,:group=>'source_code', :conditions => ["taxon_group = ? and reporter_type = ?  and group_term_id = ?  and shipment_year = ? and " + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ?  and appendix <> 'III' and origin_country_code is null and " + SourceDetails.conditions(group),
                                               group,reporter_type,term,year.to_s,country])
     end

    time << year
    data[year] = records
    year += 1
  end

  sources.each { |s|
      timearray = []
      time.each { |t|
          timearray << data[t][s.source_code]
      }
      dataarray << timearray
  }

  sources.each {|s| sourcenames << SourceDetails.source_description(s.source_code,group,false)}

  if country == nil
    yearlytotals = GlobalTradeSummary.sum(:quantity,:group=>'shipment_year', :conditions => ["taxon_group = ? and reporter_type = ?  and group_term_id = ?  and shipment_year between ? and ?  and appendix <> 'III' and " + SourceDetails.conditions(group),
                                                               group,reporter_type,term,start_year,end_year])
  else
    yearlytotals = NationalTradeSummary.sum(:quantity,:group=>'shipment_year', :conditions => ['taxon_group = ? and reporter_type = ?  and group_term_id = ?  and shipment_year between ? and ? and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ?  and appendix <> 'III' and origin_country_code is null and " + SourceDetails.conditions(group),
                                                             group,reporter_type,term,start_year,end_year,country])
  end

  results["data"] = dataarray
  results["legend"] = sourcenames
  results["axestolabel"] = 'x,y'
  results["axislabels"] = [time,get_y_axis_values(yearlytotals.values.max)]
  results["datarange"] = [0,get_y_axis_values(yearlytotals.values.max).max]
  results
end

  def self.trade_over_time(group, source, term, start_year, end_year, *national)
    results = {}
    if national.length == 0
      importerdata = GlobalTradeSummary.trade_by_year(group, 'I', source, term, start_year, end_year)
      exporterdata = GlobalTradeSummary.trade_by_year(group, 'E', source, term, start_year, end_year)
    else
      importerdata = NationalTradeSummary.trade_by_year(group, 'I', source, term, start_year, end_year,national[0],national[1])
      exporterdata = NationalTradeSummary.trade_by_year(group, 'E', source, term, start_year, end_year,national[0],national[1])
    end
    importdata = []
    exportdata = []
    chartdata = {}
    time = []
    year =  start_year

    #data & x-axis labels
    while year <= end_year
        importdata << (importerdata[year] == nil ? 0 : importerdata[year]);
        exportdata << (exporterdata[year] == nil ? 0 : exporterdata[year]);
      time << year
      year += 1
    end

    chartdata["Imports"] = importdata
    chartdata["Exports"] = exportdata

    #range for y-axis
    maxvalue = 0
    if importerdata.length > 0 and exporterdata.length > 0
      maxvalue = (importerdata.values.max > exporterdata.values.max ? importerdata.values.max : exporterdata.values.max)
    elsif  importerdata.length > 0
      maxvalue = importerdata.values.max
    elsif  exporterdata.length > 0
      maxvalue = exporterdata.values.max
    end

    results["chartdata"] = chartdata
    results["xaxislabels"] = time
    results["yaxislabels"] = self.get_y_axis_values(maxvalue.to_int)
    results["datarange"] = [0,results["yaxislabels"].max]
    if national.length > 0
      results["countryforlegend"] =   TradingCountry.find_by_iso_country_code(national[0]).short_name
    end
    results
  end

  def self.get_y_axis_values(maximum)
      if maximum == nil
        return [0]
      end

      #use string processing to round it up
      result = ""
      maxstring = maximum.ceil.to_s
      first = maxstring[0].chr.to_i + 1
      result << first.to_s
      (1..maxstring.length - 1).each{|i| result += '0'}

      #Now put the results into an array
      value = result.to_i
      quartile1 =value*0.25
      quartile2 =value*0.5
      quartile3 =value*0.75
      [0,(quartile1 == quartile1.floor ? quartile1.to_i : quartile1),(quartile2 == quartile2.floor ? quartile2.to_i : quartile2),(quartile3 == quartile3.floor ? quartile3.to_i : quartile3),value]

      #this does it to the nearest power of 10
      #result = 10**(Math.log(maximum)/Math.log(10)).ceil
  end

      def self.top_10_partner(group, term, start_year, end_year, type,source, country)
      # mattetti googlechart bar chart requires data in format [[country1source1, country2source1],[country1source2, country2source2]]
      # need to make sure that years/groups with no entry result in a nil entry in the array.

      # not possible to do multiple group by - https://rails.lighthouseapp.com/projects/8994/tickets/497-activerecord-calculate-broken-for-multiple-fields-in-group-option.
      # so can't do:
      # records = self.sum(:quantity,:group=>'shipment_year, import_country_code')
      # so need to do it in two goes

      results = {}
      partner = []  #x labels
      mapdatastring = '['
      mapdataarray = []
      partners = self.top_10_partners(group, term, start_year, end_year,type,source, country)

      dataarray = []

      partners.each {|p|
        if (type == 'E' and country != nil) || (type == 'I' and country == nil)
          partner << TradingCountry.find_by_iso_country_code(p.import_country_code).short_name#[0..14] #.chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s
          dataarray <<  p.quantity
          #mapdata needs to be passed through to js as string, and array.to_s doesn't seem to pass through the square brackets, plus ' needs to be escaped
          mapdatastring << '[\'' +  p.import_country_code + '\',' + p.quantity.to_s + ',\'' + TradingCountry.find_by_iso_country_code(p.import_country_code).name.gsub(/[']/, '\\\\\'') + '\'' + '],'
          mapdataarray << [p.import_country_code, p.quantity, TradingCountry.find_by_iso_country_code(p.import_country_code).name.gsub(/[']/, '\\\\\'')]
        elsif  (type == 'I' and country != nil) || (type == 'E' and country == nil)
          dataarray <<  p.quantity
          partner << TradingCountry.find_by_iso_country_code(p.export_country_code).short_name#[0..14] #.chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s
          mapdatastring << '[\'' +  p.export_country_code + '\',' + p.quantity.to_s + ',\'' + TradingCountry.find_by_iso_country_code(p.export_country_code).name.gsub(/[']/, '\\\\\'') + '\'' + '],'
          mapdataarray << [p.export_country_code,p.quantity,TradingCountry.find_by_iso_country_code(p.export_country_code).name.gsub(/[']/, '\\\\\'')]
        end
      }
      if mapdatastring.length > 1
         mapdatastring = mapdatastring[0..(mapdatastring.length-2)]
      end
      mapdatastring += ']'

      #y-axis labels for googlecharts need to be specified - they won't automatically scale
      maximum = partners.max{|a,b| a.quantity <=> b.quantity}
      yaxislabels = SharedTradeSummary.get_y_axis_values(maximum != nil ? maximum.quantity.to_int : 0)

      axislabels = [partner,yaxislabels]

      results["xaxislabels"] = partner
      results["data"] = dataarray.reverse
      results["mapdatastring"] = mapdatastring
      results["mapdataarray"] = mapdataarray
      results["axislabels"] = axislabels
      results["axestolabel"] = 'y,x' #horizontal
      results["datarange"] = [0,yaxislabels.max]
      results

    end

    def self.top_10_partners(group, term, start_year, end_year,type,source, country)
      if country != nil
        if source == nil
            partners = NationalTradeSummary.find_by_sql ["SELECT " + (type == "I" ? "export_country_code" : "import_country_code") + ", sum(quantity) as quantity FROM national_trade_summaries WHERE taxon_group = ?  and group_term_id = ? and " + (type == "I" ? "import_country_code" : "export_country_code") + " = ?  and shipment_year between ? and ? and reporter_type = ?  and appendix <> 'III' and origin_country_code is null GROUP BY " + (type == "I" ? "export_country_code" : "import_country_code") + " ORDER BY sum(quantity) DESC LIMIT 10",
                                       group,term,country,start_year.to_s,end_year.to_s,type]
        else
            partners = NationalTradeSummary.find_by_sql ["SELECT " + (type == "I" ? "export_country_code" : "import_country_code") + ", sum(quantity) as quantity FROM national_trade_summaries WHERE taxon_group = ?  and group_term_id = ? and " + (type == "I" ? "import_country_code" : "export_country_code") + " = ?  and shipment_year between ? and ? and reporter_type = ? and source_code = ?  and appendix <> 'III' and origin_country_code is null GROUP BY " + (type == "I" ? "export_country_code" : "import_country_code") + " ORDER BY sum(quantity) DESC LIMIT 10",
                               group,term,country,start_year.to_s,end_year.to_s,type,source]
        end
      else  #although this is a 'global' chart it needs to be broken down by country name so must use NationalTradeSummary
       if source == nil
            partners = NationalTradeSummary.find_by_sql ["SELECT " + (type == "I" ? "import_country_code" : "export_country_code") + ", sum(quantity) as quantity FROM national_trade_summaries WHERE taxon_group = ?  and group_term_id = ? and shipment_year between ? and ? and reporter_type = ?  and appendix <> 'III' and origin_country_code is null GROUP BY " + (type == "I" ? "import_country_code" : "export_country_code") + " ORDER BY sum(quantity) DESC LIMIT 10",
                                       group,term,start_year.to_s,end_year.to_s,type]
        else
            partners = NationalTradeSummary.find_by_sql ["SELECT " + (type == "I" ? "import_country_code" : "export_country_code") + ", sum(quantity) as quantity FROM national_trade_summaries WHERE taxon_group = ?  and group_term_id = ? and shipment_year between ? and ? and reporter_type = ?  and appendix <> 'III' and origin_country_code is null and source_code = ? GROUP BY " + (type == "I" ? "import_country_code" : "export_country_code") + " ORDER BY sum(quantity) DESC LIMIT 10",
                               group,term,start_year.to_s,end_year.to_s,type,source]
        end
      end
    end

      def self.top_5_term(group, start_year, end_year, type,source, country)
      data = {}
      xaxislabels = []
      dataarray = []
      results = {}
      sum = 0
      pielabels = []

      #data comes back as a hash
      if country != nil
        if source != nil
          data = NationalTradeSummary.find_by_sql ["SELECT national_trade_summaries.group_term_id, sum(quantity) as quantity FROM national_trade_summaries " + NationalTradeSummary.get_filter + " WHERE national_trade_summaries.taxon_group = ? and " + (type == "I" ? "import_country_code" : "export_country_code") + " = ?  and shipment_year between ? and ? and reporter_type = ?  and source_code = ?  and appendix <> 'III' and origin_country_code is null  GROUP BY national_trade_summaries.group_term_id ORDER BY sum(quantity) DESC LIMIT 5",
                                   group,country,start_year.to_s,end_year.to_s,type,source]
        else
          data = NationalTradeSummary.find_by_sql ["SELECT national_trade_summaries.group_term_id, sum(quantity) as quantity FROM national_trade_summaries " + NationalTradeSummary.get_filter + " WHERE national_trade_summaries.taxon_group = ? and " + (type == "I" ? "import_country_code" : "export_country_code") + " = ?  and shipment_year between ? and ? and reporter_type = ?  and appendix <> 'III' and origin_country_code is null GROUP BY national_trade_summaries.group_term_id ORDER BY sum(quantity) DESC LIMIT 5",
                                   group,country,start_year.to_s,end_year.to_s,type]
        end
      else
        if source != nil
          data = GlobalTradeSummary.find_by_sql ["SELECT global_trade_summaries.group_term_id, sum(quantity) as quantity FROM global_trade_summaries " + GlobalTradeSummary.get_filter + " WHERE global_trade_summaries.taxon_group = ? and shipment_year between ? and ? and reporter_type = ?  and source_code = ?  and appendix <> 'III'  GROUP BY global_trade_summaries.group_term_id ORDER BY sum(quantity) DESC LIMIT 5",
                                   group,start_year.to_s,end_year.to_s,type,source]
        else
          data = GlobalTradeSummary.find_by_sql ["SELECT global_trade_summaries.group_term_id, sum(quantity) as quantity FROM global_trade_summaries " + GlobalTradeSummary.get_filter + " WHERE global_trade_summaries.taxon_group = ? and shipment_year between ? and ? and reporter_type = ?  and appendix <> 'III' GROUP BY global_trade_summaries.group_term_id ORDER BY sum(quantity) DESC LIMIT 5",
                                   group,start_year.to_s,end_year.to_s,type]
        end
      end
      data.each { |x| sum += x.quantity }

      #chart needs two arrays, data and labels
      data.each {|d|
        description = GroupTerm.term_description_short(d.group_term_id)
        dataarray <<  d.quantity
        xaxislabels << description
        pielabels << description + ': ' + "%.1f" % (d.quantity/sum*100)  + '%'
      }

      #y-axis labels need to be specified - they won't automatically scale
      yaxislabels = SharedTradeSummary.get_y_axis_values(dataarray.max)

      results["xaxislabels"] = xaxislabels
      results["data"] = dataarray.reverse #this one is horizontal
      results["axislabels"] = [xaxislabels,yaxislabels]
      results["axestolabel"] = 'y,x' #this one is horizontal
      results["datarange"] = [0,yaxislabels.max]
      results["pielabels"] = [pielabels,yaxislabels]
      results

      end

      def self.trade_by_appendix(group, term, start_year, end_year, reporter_type,source, country)
        data = {}
        xaxislabels = []
        dataarray = []
        results = {}
        sum = 0
        pielabels = []


        #data comes back as a hash
        if country != nil
          if source != nil
            data = NationalTradeSummary.sum(:quantity, :group=>:appendix, :order => :appendix, :conditions => ['taxon_group = ? and reporter_type = ? and group_term_id = ? and shipment_year between ? and ? and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and source_code = ? and origin_country_code is null" ,
                                                                       group,reporter_type,term,start_year,end_year,country,source])
            sum = NationalTradeSummary.sum(:quantity, :conditions => ['taxon_group = ? and reporter_type = ? and group_term_id = ? and shipment_year between ? and ? and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and source_code = ? and origin_country_code is null" ,
                                                                       group,reporter_type,term,start_year,end_year,country,source])
          else
            data = NationalTradeSummary.sum(:quantity, :group=>:appendix, :order => :appendix,  :conditions => ['taxon_group = ? and reporter_type = ?  and group_term_id = ? and shipment_year between ? and ? and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and origin_country_code is null",
                                                                         group,reporter_type,term,start_year,end_year,country])
            sum = NationalTradeSummary.sum(:quantity,  :conditions => ['taxon_group = ? and reporter_type = ?  and group_term_id = ? and shipment_year between ? and ? and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and origin_country_code is null",
                                                                         group,reporter_type,term,start_year,end_year,country])
          end
        else
          if source != nil
            data = GlobalTradeSummary.sum(:quantity, :group=>:appendix, :order => :appendix,  :conditions => ["taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ?",
                                                                       group,reporter_type,source,term,start_year,end_year])
            sum = GlobalTradeSummary.sum(:quantity, :conditions => ["taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ?",
                                                                       group,reporter_type,source,term,start_year,end_year])
          else
             data = GlobalTradeSummary.sum(:quantity, :group=>:appendix, :order => :appendix,  :conditions => ["taxon_group = ? and reporter_type = ?  and group_term_id = ? and shipment_year between ? and ?",
                                                                         group,reporter_type,term,start_year,end_year])
             sum = GlobalTradeSummary.sum(:quantity, :conditions => ["taxon_group = ? and reporter_type = ?  and group_term_id = ? and shipment_year between ? and ?",
                                                                         group,reporter_type,term,start_year,end_year])
          end
        end


        #standard chart needs two arrays, data and labels.  Now
        chartdatastackedarray = []
        ["I","II","III"].each_with_index {|a,i|
          chartdataarray = [0,0,0]
          if data[a] != nil
            dataarray <<  data[a]
            chartdataarray[i] = data[a]
            xaxislabels << a
            pielabels << a + ': ' + "%.1f" % (data[a]/sum*100)  + '%'
          elsif
            dataarray << 0
            xaxislabels << a
            pielabels << ''
          end
          chartdatastackedarray <<  chartdataarray
        }

        #y-axis labels need to be specified - they won't automatically scale
        yaxislabels = SharedTradeSummary.get_y_axis_values(dataarray.max)

        results["xaxislabels"] = xaxislabels
        results["data"] = dataarray
        results["stackeddata"] = chartdatastackedarray
        results["axislabels"] = [xaxislabels,yaxislabels]
        results["axestolabel"] = 'x,y'
        results["datarange"] = [0,yaxislabels.max]
        results["pielabels"] = [pielabels,yaxislabels]
        results
      end

      def self.top_species(group, term, start_year, end_year, reporter_type,source, country)
      data = {}
      xaxislabels = []
      dataarray = []
      speciesarray = []
      results = {}

      #This table has been set up to have 'All sources' as ''
      if source == nil
        source = 'All'
      end
      #data comes back as a hash
      if country != nil
          #data = TopSpecies.sum(:quantity, :limit => 10, :group => "cites_name,cites_taxon_code", :order => "sum(quantity) desc", :conditions => ['taxon_group = ? and reporter_type = ? and group_term_id = ? and shipment_year between ? and ? and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + ' = ? and source_code = ? ' ,
          #                                                          group,reporter_type,term,start_year,end_year,country,source])
          data = TopSpecies.find_by_sql ["SELECT cites_name,cites_taxon_code, sum(quantity) as quantity FROM top_species WHERE taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ? and " + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? GROUP BY cites_name,cites_taxon_code ORDER BY sum(quantity) DESC",
                                                                    group,reporter_type,source,term,start_year,end_year,country]
      else
          #data = TopSpecies.sum(:quantity, :limit => 10, :group => "cites_name,cites_taxon_code", :order => "sum(quantity) desc", :conditions => ['taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ? and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + ' = ?',
          #                                                           group,reporter_type,source,term,start_year,end_year,'Global'])
          data = TopSpecies.find_by_sql ["SELECT cites_name,cites_taxon_code, sum(quantity) as quantity FROM top_species WHERE taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ? and " + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? GROUP BY cites_name,cites_taxon_code ORDER BY sum(quantity) DESC",
                                                                    group,reporter_type,source,term,start_year,end_year,'Global']
      end

      #chart needs two arrays, data and labels
      data.each {|d|
        dataarray <<  d["quantity"]
        speciesarray << d["cites_taxon_code"]
        xaxislabels << d["cites_name"]
      }

      #y-axis labels need to be specified - they won't automatically scale
      yaxislabels = SharedTradeSummary.get_y_axis_values(dataarray.max)

      results["xaxislabels"] = xaxislabels
      results["data"] = dataarray.reverse  #values to go along x-axis
      results["axislabels"] = [xaxislabels,yaxislabels]
      results["axestolabel"] = 'y,x' #values to go along x-axis
      results["datarange"] = [0,yaxislabels.max]
      results["species"] = speciesarray
      results

  end

  def self.species_over_time(species, reporter_type, source, term, start_year, end_year, country)
      data = {}
      xaxislabels = []
      dataarray = []
      results = {}

    #data comes back as a hash
    if source != nil
      if country != nil
          data = SpeciesTradeSummary.sum(:quantity, :group=>:shipment_year, :conditions => ['cites_taxon_code = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ?and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ?  and appendix <> 'III' and origin_country_code is null",
                                                                   species,reporter_type,source,term,start_year,end_year,country])
      else
          data = SpeciesTradeSummary.sum(:quantity, :group=>:shipment_year, :conditions => ["cites_taxon_code = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ? and appendix <> 'III' and origin_country_code is null",
                                                                   species,reporter_type,source,term,start_year,end_year])
      end
    else
      if country != nil
          data = SpeciesTradeSummary.sum(:quantity, :group=>:shipment_year, :conditions => ['cites_taxon_code = ? and reporter_type = ? and group_term_id = ? and shipment_year between ? and ?and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and appendix <> 'III' and origin_country_code is null",
                                                                   species,reporter_type,term,start_year,end_year,country])
      else
          data = SpeciesTradeSummary.sum(:quantity, :group=>:shipment_year, :conditions => ["cites_taxon_code = ? and reporter_type = ? and group_term_id = ? and shipment_year between ? and ? and appendix <> 'III' and origin_country_code is null",
                                                                   species,reporter_type,term,start_year,end_year])
      end
    end

    year =  start_year
    #data & x-axis labels
    while year <= end_year
      dataarray << (data[year] == nil ? 0 : data[year]);
      xaxislabels << year
      year += 1
    end

      #y-axis labels need to be specified - they won't automatically scale
      yaxislabels = SharedTradeSummary.get_y_axis_values(dataarray.max)

      results["xaxislabels"] = xaxislabels
      results["data"] = dataarray
      results["axislabels"] = [xaxislabels,yaxislabels]
      results["axestolabel"] = 'x,y' 
      results["datarange"] = [0,yaxislabels.max]
      results
    end
  def self.top_families(group, term, start_year, end_year, reporter_type,source, country)
     data = {}
     xaxislabels = []
     dataarray = []
     results = {}

     #This table has been set up to have 'All sources' as ''
     if source == nil
       source = 'All'
     end
     #data comes back as a hash
     if country != nil
         data = TopFamilies.sum(:quantity, :limit => 10, :group => "taxon_family", :order => "sum(quantity) desc", :conditions => ['taxon_group = ? and reporter_type = ? and group_term_id = ? and shipment_year between ? and ? and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and source_code = ?" ,
                                                                   group,reporter_type,term,start_year,end_year,country,source])
         #data = TopSpecies.find_by_sql ["SELECT cites_name,cites_taxon_code, sum(quantity) as quantity FROM top_species WHERE taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ? and " + (reporter_type == "I" ? "import_country_code" : "export_country_code") + ' = ? GROUP BY cites_name,cites_taxon_code ORDER BY sum(quantity) DESC',
         #                                                          group,reporter_type,source,term,start_year,end_year,country]
     else
         data = TopFamilies.sum(:quantity, :limit => 10, :group => "taxon_family", :order => "sum(quantity) desc", :conditions => ['taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ? and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ?",
                                                                    group,reporter_type,source,term,start_year,end_year,'Global'])
         #data = TopSpecies.find_by_sql ["SELECT cites_name,cites_taxon_code, sum(quantity) as quantity FROM top_species WHERE taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ? and " + (reporter_type == "I" ? "import_country_code" : "export_country_code") + ' = ? GROUP BY cites_name,cites_taxon_code ORDER BY sum(quantity) DESC',
         #                                                          group,reporter_type,source,term,start_year,end_year,'Global']
     end

     #chart needs two arrays, data and labels
     data.each {|d|
       dataarray <<  d[1]
       xaxislabels << d[0]
     }

     #y-axis labels need to be specified - they won't automatically scale
     yaxislabels = SharedTradeSummary.get_y_axis_values(dataarray.max)

     results["xaxislabels"] = xaxislabels
     results["data"] = dataarray.reverse  #values to go along x-axis
     results["axislabels"] = [xaxislabels,yaxislabels]
     results["axestolabel"] = 'y,x' #values to go along x-axis
     results["datarange"] = [0,yaxislabels.max]
     results
 end

 def self.families_over_time(familyname, reporter_type, source, term, start_year, end_year, country)
     data = {}
     xaxislabels = []
     dataarray = []
     results = {}

   #data comes back as a hash
   if source != nil
     if country != nil
         data = FamiliesTradeSummary.sum(:quantity, :group=>:shipment_year, :conditions => ['taxon_family = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ?and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and appendix <> 'III' and origin_country_code is null",
                                                                  familyname,reporter_type,source,term,start_year,end_year,country])
     else
         data = FamiliesTradeSummary.sum(:quantity, :group=>:shipment_year, :conditions => ["taxon_family = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ?  and appendix <> 'III' and origin_country_code is null ",
                                                                  familyname,reporter_type,source,term,start_year,end_year])
     end
   else
     if country != nil
         data = FamiliesTradeSummary.sum(:quantity, :group=>:shipment_year, :conditions => ['taxon_family = ? and reporter_type = ? and group_term_id = ? and shipment_year between ? and ?and ' + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and appendix <> 'III' and origin_country_code is null",
                                                                  familyname,reporter_type,term,start_year,end_year,country])
     else
         data = FamiliesTradeSummary.sum(:quantity, :group=>:shipment_year, :conditions => ["taxon_family = ? and reporter_type = ? and group_term_id = ? and shipment_year between ? and ?  and appendix <> 'III' and origin_country_code is null",
                                                                  familyname,reporter_type,term,start_year,end_year])
     end
   end

   year =  start_year
   #data & x-axis labels
   while year <= end_year
     dataarray << (data[year] == nil ? 0 : data[year]);
     xaxislabels << year
     year += 1
   end

     #y-axis labels need to be specified - they won't automatically scale
     yaxislabels = SharedTradeSummary.get_y_axis_values(dataarray.max)

     results["xaxislabels"] = xaxislabels
     results["data"] = dataarray
     results["axislabels"] = [xaxislabels,yaxislabels]
     results["axestolabel"] = 'x,y'
     results["datarange"] = [0,yaxislabels.max]
     results
   end

end