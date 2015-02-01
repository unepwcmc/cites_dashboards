class SharedController < ApplicationController
  def generate_top_10_partner(type)
      if @controlpanel.class == NationalControlPanel
        sources =  SharedTradeSummary.top_10_partner(@controlpanel.group,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],type,@controlpanel.source,@controlpanel.country)
      else
        sources =  SharedTradeSummary.top_10_partner(@controlpanel.group,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],type,@controlpanel.source,nil)
      end      
      if sources["xaxislabels"].length > 0 #i.e. we have data
        #calculate appropriate width for chart
        @chart = get_bar_chart(sources, 'horizontal', 'chxtc=0,10|1,10|2,10',{:spacing => 5,:width => 15},nil,'550x250')        
        @mapdata = sources["mapdatastring"]
        @mapdataarray = sources["mapdataarray"]
      else
        @chart = "No data for this selection"
        @mapdata = "[]"
        @mapdataarray = []
      end

      if @controlpanel.class == NationalControlPanel
        @reporttype = (type == "E" ? " Importing countries" : " Exporting countries")
        @legend = "Top 10" + (type == "E" ? " importers" : " exporters") + " of " + @controlpanel.group.downcase + (type == "E" ? " from " : " to ") + @controlpanel.countrydescription
      else
        @reporttype = (type == "I" ? " Importing countries" : " Exporting countries")
        @legend = "Top 10 " + (type == "I" ? " importers " : " exporters ") + "<br /> (as reported by" + (type == "I" ? " importers" : " exporters") + ")"
      end
    end

  def generate_top_5_term
       if @controlpanel.class == NationalControlPanel
         sources =  SharedTradeSummary.top_5_term(@controlpanel.group,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.reportertype,@controlpanel.source,@controlpanel.country)
       else
         sources =  SharedTradeSummary.top_5_term(@controlpanel.group,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.reportertype,@controlpanel.source,nil)
      end

      @chart = sources["xaxislabels"].length > 0 ? get_pie_chart(sources,'horizontal') + get_bar_chart(sources,'horizontal', 'chxtc=0,10|1,10',{:spacing => 6,:width => 35},'','400x250') : "No data for this selection"
      @reporttype = "Terms in trade"
      if @controlpanel.class == NationalControlPanel
        @legend = 'Top five trade terms ' + (@controlpanel.reportertype == "I" ? " imported " : " exported ") + ' by ' + @controlpanel.countrydescription
      else
        @legend = 'Top five terms in trade <br /> (as reported by' + (@controlpanel.reportertype == "I" ? " importers" : " exporters") + ")"
      end

  end

  def generate_appendix
       if @controlpanel.class == NationalControlPanel
         sources =  SharedTradeSummary.trade_by_appendix(@controlpanel.group,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.reportertype,@controlpanel.source,@controlpanel.country)
       else
         sources =  SharedTradeSummary.trade_by_appendix(@controlpanel.group,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.reportertype,@controlpanel.source,nil)
      end

      if sources["data"].sum > 0
      chart = Gchart.bar(:size => '270x250',
                    :bar_width_and_spacing => {:spacing => 6, :width => 40},
                    :data => sources["stackeddata"], :encoding => 'text',
                    :axis_with_labels => sources["axestolabel"] << ',y',
                    :axis_labels => sources["axislabels"] << GroupTerm.term_description(@controlpanel.term),
                    :axis_range => [[0,0,sources["datarange"][1]],[0,0,sources["datarange"][1]],[0,0,sources["datarange"][1]]],
                    :bar_colors => ['01665E','67A39F','CDE1DF'],
                    :custom => 'chxtc=0,10|1,10&chxp=2,' + calculate_y_axis_midpoint(sources["stackeddata"],sources["datarange"][1]),
                    :max_value =>  sources["datarange"][1],
                    :format => 'image_tag').to_s
      end
      @chart = sources["data"].sum > 0 ? get_pie_chart(sources,'vertical','360x250',['01665E','67A39F','CDE1DF']) + chart : "No data for this selection"

      @reporttype = "Trade by Appendix"
      if @controlpanel.class == NationalControlPanel
        @legend = (@controlpanel.reportertype == "I" ? "Imports " : " Exports ") + ' of '  + @controlpanel.group + ' by CITES Appendix'
      else
        @legend = 'Trade by CITES Appendix <br /> (as reported by' + (@controlpanel.reportertype == "I" ? " importers" : " exporters") + ")"
      end

  end

  def generate_top_10_species
      sources =  SharedTradeSummary.top_species(@controlpanel.group,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.reportertype,@controlpanel.source, @controlpanel.class == NationalControlPanel ? @controlpanel.country : nil)
      @chart = sources["xaxislabels"].length > 0 ? get_bar_chart(sources,'horizontal','chxtc=0,10|1,10',{:spacing => 5,:width => 15},nil,'600x250') +  generate_species_trade(sources["species"][0],sources) : "No data for this selection"
      @reporttype = "Top Species in Trade"
      if @controlpanel.class == NationalControlPanel
        @legend = 'Top ten ' + @controlpanel.group.downcase.singularize + ' species ' + (@controlpanel.reportertype == "I" ? "imported " : " exported ") + ' by ' + @controlpanel.countrydescription
      else
        @legend = 'Top ten ' + @controlpanel.group.downcase + ' in trade <br /> (as reported by' + (@controlpanel.reportertype == "I" ? " importers" : " exporters") + ")"
      end
  end

  def generate_species_trade(speciescode,sources)
    trade =   SharedTradeSummary.species_over_time(speciescode, @controlpanel.reportertype, @controlpanel.source, @controlpanel.term, @controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'], @controlpanel.class == NationalControlPanel ? @controlpanel.country : nil)
    @sources = sources
    @speciescode = speciescode
    @barchart = get_bar_chart(trade,'vertical','chxtc=0,10|1,10',{:spacing => 5,:width => 25},nil,'410x250')
    render_to_string :partial => 'shared/load_species_chart'
  end

    def generate_top_10_families
      sources =  SharedTradeSummary.top_families(@controlpanel.group,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.reportertype,@controlpanel.source, @controlpanel.class == NationalControlPanel ? @controlpanel.country : nil)
      @chart = sources["xaxislabels"].length > 0 ? get_bar_chart(sources,'horizontal','chxtc=0,10|1,10',{:spacing => 5,:width => 15}, nil, '600x250') +  generate_families_trade(sources["xaxislabels"][0],sources) : "No data for this selection"
      @reporttype = "Top Families in Trade"
      if @controlpanel.class == NationalControlPanel
        @legend = 'Top ten ' + @controlpanel.group.downcase.singularize + ' Families ' + (@controlpanel.reportertype == "I" ? "imported " : "exported ") + ' by ' + @controlpanel.countrydescription
      else
        @legend = 'Top ten ' + @controlpanel.group.downcase.singularize + ' Families ' + 'in trade <br /> (as reported by' + (@controlpanel.reportertype == "I" ? " importers" : " exporters") + ")"
      end
  end

  def generate_families_trade(familyname,sources)
    trade =   SharedTradeSummary.families_over_time(familyname, @controlpanel.reportertype, @controlpanel.source, @controlpanel.term, @controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'], @controlpanel.class == NationalControlPanel ? @controlpanel.country : nil)
     @sources = sources
     @familyname = familyname
     @barchart = get_bar_chart(trade,'vertical','chxtc=0,10|1,10',{:spacing => 5,:width => 25},(@controlpanel.reportertype == "I" ? " Imports " : " Exports ") + " of #{familyname}",'410x250')
     render_to_string :partial => 'shared/load_families_chart'
  end
    
  def load_species_chart()
    @controlpanel = session[:controlpanel]
    sources =  SharedTradeSummary.top_species(@controlpanel.group,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.reportertype,@controlpanel.source, @controlpanel.class == NationalControlPanel ? @controlpanel.country : nil)
    render :text => generate_species_trade(params[:speciescode],sources)
  end


  def load_families_chart()
   @controlpanel = session[:controlpanel]
   sources =  SharedTradeSummary.top_families(@controlpanel.group,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.reportertype,@controlpanel.source, @controlpanel.class == NationalControlPanel ? @controlpanel.country : nil)
   render :text => generate_families_trade(params[:familyname],sources)
  end

  def generate_sources
    barcolours = ['543005','8C510A','BF812D','DFC27D','F6E8C3','C7EAE5','80CDC1','35978F','01665E'].reverse
    exportersources =  SharedTradeSummary.trade_by_year_by_source(@controlpanel.group,@controlpanel.reportertype,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'], @controlpanel.class == NationalControlPanel ? @controlpanel.country : nil)
    piesources = SharedTradeSummary.trade_by_source(@controlpanel.group,@controlpanel.reportertype,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'], @controlpanel.class == NationalControlPanel ? @controlpanel.country : nil)
    pie = 'No data for this selection'
    if piesources[0].length > 0
      pie = Gchart.pie(:size => '600x250',
                    :data => piesources[0],
                    :labels => piesources[1],
                    :bar_colors => barcolours[0..piesources[0].length-1],
                    #:custom => "chp=-1.57",
                    :format => 'image_tag').to_s

      if exportersources["legend"].include?("Artificially propagated (App. I, commercial) (D)")
        size = '585x269'
      elsif exportersources["legend"].include?("Captive-bred (App. I, commercial) (D)")
        size = '535x269'
      else
        size = '425x269'
      end
      @chart = #pie + get_bar_chart(exportersources,'vertical','chxtc=0,10|1,10',{:spacing => 8, :width => 27},nil,size,exportersources["legend"],barcolours)
             pie + Gchart.bar(:size => size,
                    :bar_width_and_spacing => {:spacing => 8, :width => 27},
                    :legend => exportersources["legend"],
                    :data => exportersources["data"],
                    :axis_with_labels => exportersources["axestolabel"] << ',y',
                    :axis_labels => exportersources["axislabels"] << GroupTerm.term_description(@controlpanel.term),
                    :bar_colors => barcolours,
                    :custom => 'chxtc=0,10|1,10&chxp=2,' + calculate_y_axis_midpoint(exportersources["data"],exportersources["datarange"][1]),
                    :max_value =>  exportersources["datarange"][1],
                    :format => 'image_tag').to_s
    else
      @chart = "No data for this selection"
    end
    @reporttype = "Trade by source"
    if @controlpanel.class == NationalControlPanel
      @legend = 'Source of ' + @controlpanel.group + (@controlpanel.reportertype == "I" ? " imported " : " exported ") + ' by ' + @controlpanel.countrydescription
    else
      @legend = 'Trade by Source <br />(as reported by' + (@controlpanel.reportertype == "I" ? " importers" : " exporters") +  ')'
    end
  end

private
  def get_bar_chart(source, orientation='vertical',tickmarks='',spacing={:spacing => 6,:width => 40},title='',size='300x250',barcolors=['01665E'])
    Gchart.bar(:size => size,                                                     #chs
                        :bar_width_and_spacing => spacing,                        #chbh
                        :data => source["data"], :encoding => 'text',             #chd
                        :orientation => orientation,                              #cht
                        :axis_with_labels => (source["axestolabel"] << (orientation == 'vertical' ? ',y' : ',x')),     #chxt
                        :axis_labels => (source["axislabels"] << GroupTerm.term_description(@controlpanel.term)),        #chxl
                        :bar_colors => barcolors,                                #chco
                        :title => title,
                        #:legend => legend,
                        :max_value =>  source["datarange"][1],                    #Need to set scale on both data (chds) and axis (chxr)
                        :custom => (tickmarks != nil ? (tickmarks + '&') : 'chxtc=0,10|1,10&') + 'chxp=' + (source["axislabels"].length-1).to_s + ',50', #chxtc
                        :format => 'image_tag',
                        :class => "barchart").to_s.gsub("%26","&").gsub("%3B",";").gsub('+&+','+%26+') #need to retain code for & in country names
  end

  def get_pie_chart(source, alignment,size='600x250',barcolours=['01665E'])
    Gchart.pie(:size => size,
                        :bar_width_and_spacing => {:spacing => 6,:width => 40},
                        :data => alignment == 'horizontal' ? source["data"].reverse : source["data"],
                        :encoding => 'text',
                        :axis_with_labels => 'x',
                        :axis_labels => source["pielabels"],
                        :bar_colors => barcolours,
                        :max_value =>  source["datarange"][1],
                        :format => 'image_tag').to_s
  end

  def calculate_y_axis_midpoint(data,maxvalue)  #tries to solve y-axis label alignment problem when there are multiple chxr values 
    if data.length == 1                         #Only seems to affect data with > 1 series
      return '50'                               #This seems to work as the default if there's only one series
    end

    minvalue = 0    
    if data.length == 2 && data[1][0] != nil
      minvalue = data[1][0]                      #Need the first value of the second data series (will come out as chxr 2)
    elsif data.length > 2 && data[2][0] != nil
      minvalue = data[2][0]
    end
    midvalue = (maxvalue - minvalue)/2.to_f     #Ruby defaults to integer division, will be noticeable if maxvalue small
    (minvalue + midvalue).to_s
  end
end
