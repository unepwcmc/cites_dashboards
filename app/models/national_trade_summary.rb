class NationalTradeSummary < ActiveRecord::Base
    def self.top_10_partner_grouped_by_source(group, term, country, start_year, end_year, type)
      # mattetti googlechart bar chart requires data in format [[country1source1, country2source1],[country1source2, country2source2]]
      # need to make sure that years/groups with no entry result in a nil entry in the array.

      # not possible to do multiple group by - https://rails.lighthouseapp.com/projects/8994/tickets/497-activerecord-calculate-broken-for-multiple-fields-in-group-option.
      # so can't do:
      # records = self.sum(:quantity,:group=>'shipment_year, import_country_code')
      # so need to do it in two goes

      results = {}
      data = {}
      partner = []
      mapdatastring = '['
      mapdataarray = []
      partners = self.top_10_partners(group, term, country, start_year, end_year,type,nil)

      dataarray = []
      sources = SourceDetails.find(:all, :order => 'source_english_name', :conditions => "source_code <> 'I'")
      sourcenames = []
      partners.each {|p|
        records = self.get_partner_details(p,group, term, country, start_year, end_year,type)
        if type == 'I'
          partner << TradingCountry.find_by_iso_country_code(p.import_country_code).name[0..13]
          data[p.import_country_code] = records
          #mapdata needs to be passed through to js as string, and array.to_s doesn't seem to pass through the square brackets, plus ' needs to be escaped
          mapdatastring << '[\'' +  p.import_country_code + '\',' + p.quantity.to_s + ',\'' + TradingCountry.find_by_iso_country_code(p.import_country_code).name.gsub(/[']/, '\\\\\'') + '\'' + '],'
          mapdataarray << [p.import_country_code, p.quantity, TradingCountry.find_by_iso_country_code(p.import_country_code).name.gsub(/[']/, '\\\\\'')]
        else
          #partner << p.iso_english_short_name
          partner << TradingCountry.find_by_iso_country_code(p.export_country_code).name[0..13]
          data[p.export_country_code] = records
          mapdatastring << '[\'' +  p.export_country_code + '\',' + p.quantity.to_s + ',\'' + TradingCountry.find_by_iso_country_code(p.export_country_code).name.gsub(/[']/, '\\\\\'') + '\'' + '],'
          mapdataarray << [p.export_country_code,p.quantity,TradingCountry.find_by_iso_country_code(p.export_country_code).name.gsub(/[']/, '\\\\\'')]
        end
      }
      if mapdatastring.length > 1
         mapdatastring = mapdatastring[0..(mapdatastring.length-2)]
      end
      mapdatastring += ']'

      sources.each { |s|
          partnerarray = []
          partners.each { |p|
              if type == 'I'
                partnerarray << data[p.import_country_code][s.source_code]
              else
                partnerarray << data[p.export_country_code][s.source_code]
              end
          }
          dataarray << partnerarray
      }

      sources.each {|s| sourcenames << s.source_english_name}
      axislabels = [''] # not sure how googlecharts calculates the starting value, so leave it blank for time being
      maximum = partners.max{|a,b| a.quantity <=> b.quantity}
      axislabels << (maximum != nil ? maximum.quantity.to_int : 0)

      results["partners"] = partner
      results["data"] = dataarray
      results["sources"] = sourcenames
      results["mapdatastring"] = mapdatastring
      results["mapdataarray"] = mapdataarray
      results["axislabels"] = axislabels
      results

    end

    def self.get_partner_details(p,group, term, country, start_year, end_year,type)
        if (type == 'I')
        records = self.sum(:quantity,:group=>'source_code',
                      :conditions => ["taxon_group = ? and export_country_code = ?  and term_code = ? and import_country_code = ?  and shipment_year between ? and ? and reporter_type = ? and appendix <> 'III' and origin_country_code is null",
                                                              group,country,term,p.import_country_code,start_year.to_s,end_year.to_s,'E'])
        else
          records = self.sum(:quantity,:group=>'source_code',
                        :conditions => ["taxon_group = ? and import_country_code = ?  and term_code = ? and export_country_code = ?  and shipment_year between ? and ? and reporter_type = ? and appendix <> 'III' and origin_country_code is null",
                                                                 group,country,term,p.export_country_code,start_year.to_s,end_year.to_s,'I'])
        end
        records
    end

  def self.trade_by_year(group, series, source, term, start_year, end_year,country,reportertype)
    if source != nil
      self.sum(:quantity, :group=>:shipment_year, :conditions => ['taxon_group = ? and reporter_type = ? and term_code = ? and shipment_year between ? and ? and ' + (reportertype == "I" ? "import_country_code" : "export_country_code") + " = ? and source_code = ?  and appendix <> 'III' and origin_country_code is null " ,
                                                                 group,series,term,start_year,end_year,country,source])
    else
       self.sum(:quantity, :group=>:shipment_year, :conditions => ['taxon_group = ? and reporter_type = ?  and group_term_id = ? and shipment_year between ? and ? and ' + (reportertype == "I" ? "import_country_code" : "export_country_code") + " = ? and appendix <> 'III' and origin_country_code is null",
                                                                   group,series,term,start_year,end_year,country])
    end
  end

  def self.reexports(group, term, start_year, end_year, type,source, country)
      #This needs to generate a map showing the top 10 partners but a chart showing the trade over time
      results = {}
      mapdatastring = '['
      mapdataarray = []
      partners = self.top_10_reexport_partners(group, term, start_year, end_year,type,source, country)

      partners.each {|p|
        if (type == 'E' and country != nil) || (type == 'I' and country == nil)
           #mapdata needs to be passed through to js as string, and array.to_s doesn't seem to pass through the square brackets, plus ' needs to be escaped
          mapdatastring << '[\'' +  p.origin_country_code + '\',' + p.quantity.to_s + ',\'' + TradingCountry.find_by_iso_country_code(p.origin_country_code).name.gsub(/[']/, '\\\\\'') + '\'' + '],'
          mapdataarray << [p.origin_country_code, p.quantity, TradingCountry.find_by_iso_country_code(p.origin_country_code).name.gsub(/[']/, '\\\\\'')]
        elsif  (type == 'I' and country != nil) || (type == 'E' and country == nil)
            mapdatastring << '[\'' +  p.export_country_code + '\',' + p.quantity.to_s + ',\'' + TradingCountry.find_by_iso_country_code(p.export_country_code).name.gsub(/[']/, '\\\\\'') + '\'' + '],'
          mapdataarray << [p.export_country_code,p.quantity,TradingCountry.find_by_iso_country_code(p.export_country_code).name.gsub(/[']/, '\\\\\'')]
        end
      }
      if mapdatastring.length > 1
         mapdatastring = mapdatastring[0..(mapdatastring.length-2)]
      end
      mapdatastring += ']'

      results = self.reexports_over_time(group, type, source, term, start_year, end_year, country)
      results["mapdatastring"] = mapdatastring
      results["mapdataarray"] = mapdataarray
      results

    end

    def self.top_10_reexport_partners(group, term, start_year, end_year,type,source, country)
        if source == nil
            partners = self.find_by_sql ["SELECT " + (type == "I" ? "export_country_code" : "origin_country_code") + ", sum(quantity) as quantity FROM national_trade_summaries WHERE taxon_group = ?  and group_term_id = ? and " + (type == "I" ? "import_country_code" : "export_country_code") + " = ?  and shipment_year between ? and ? and reporter_type = ? and origin_country_code <> '' and appendix <> 'III' GROUP BY " + (type == "I" ? "export_country_code" : "origin_country_code") + " ORDER BY sum(quantity) DESC LIMIT 10",
                                       group,term,country,start_year.to_s,end_year.to_s,type]
        else
            partners = self.find_by_sql ["SELECT " + (type == "I" ? "export_country_code" : "origin_country_code") + ", sum(quantity) as quantity FROM national_trade_summaries WHERE taxon_group = ?  and group_term_id = ? and " + (type == "I" ? "import_country_code" : "export_country_code") + " = ?  and shipment_year between ? and ? and reporter_type = ? and origin_country_code <> '' and appendix <> 'III' and source_code = ? GROUP BY " + (type == "I" ? "export_country_code" : "origin_country_code") + " ORDER BY sum(quantity) DESC LIMIT 10",
                               group,term,country,start_year.to_s,end_year.to_s,type,source]
        end
    end

  def self.reexports_over_time(group, reporter_type, source, term, start_year, end_year, country)
      data = {}
      xaxislabels = []
      dataarray = []
      results = {}

    #data comes back as a hash
    if source != nil
        data = self.sum(:quantity, :group=>:shipment_year, :conditions => ["taxon_group = ? and reporter_type = ? and source_code = ?  and group_term_id = ? and shipment_year between ? and ?  and " + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and origin_country_code <> ''  and appendix <> 'III'",
                                                                 group,reporter_type,source,term,start_year,end_year,country])
    else
        data = self.sum(:quantity, :group=>:shipment_year, :conditions => ["taxon_group = ? and reporter_type = ? and group_term_id = ? and shipment_year between ? and ? and " + (reporter_type == "I" ? "import_country_code" : "export_country_code") + " = ? and origin_country_code <> ''  and appendix <> 'III'",
                                                                 group,reporter_type,term,start_year,end_year,country])
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

  def self.maxdate
    2014
  end

  def self.mindate
    1975
  end

  def self.get_filter
    " INNER JOIN group_terms on group_terms.taxon_group = national_trade_summaries.taxon_group and group_terms.term_code = national_trade_summaries.term_code "
  end
end
