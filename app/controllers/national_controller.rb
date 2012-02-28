class NationalController < SharedController
  @bannersource = '<img src="../images/taxonomic1.gif" alt="Banner Logo"/>' 
  def index
    if params[:id] == nil and session[:controlpanel] != nil and session[:controlpanel].class == NationalControlPanel
      @controlpanel = session[:controlpanel]
    else
      @controlpanel = NationalControlPanel.new({:group => "Mammals",
                                              :country=> params[:id] != nil ? params[:id] : "BR" ,
                                              :date_range=>"2008",
                                              :term=>GroupTerm.default("Mammals"),
                                              :source=>'All',
                                              :display=>"Time",
                                              :reportertype => "I"})
    end
    @tradingcountry = TradingCountry.find(@controlpanel.country)
    @distribution = {}
  #rescue
  #  render :text => "Sorry, an error has occurred while processing your request"
  end

  def load_chart
    @controlpanel = NationalControlPanel.new(params[:controlpanel])
    @tradingcountry = TradingCountry.find(@controlpanel.country)
    if session[:group] != @controlpanel.group
      @controlpanel.term = GroupTerm.default(@controlpanel.group)
    end
    generate_chart
    render :template => 'shared/load_chart'
  end

private
  def  generate_chart
    @tradingcountry = TradingCountry.find(@controlpanel.country)
    @distribution = {}
    case @controlpanel.display
      when "Importers"
        generate_top_10_partner("E")
      when "Exporters"
        generate_top_10_partner("I")
      when "Terms"
        generate_top_5_term
      when "Sources"
        generate_sources
      when "Time"
        generate_trade_over_time
      when "Appendix"
        generate_appendix
      when "Species"
        generate_top_10_species
      when "Families"
        generate_top_10_families
      when "Re-exports"
        generate_reexports
      when "Distribution"
        load_species_distribution
    end
  end

  def generate_trade_over_time
      results =  SharedTradeSummary.trade_over_time(@controlpanel.group,@controlpanel.source,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.country,@controlpanel.reportertype)
      legend = [(@controlpanel.reportertype == "I" ? "Imports" : "Exports") + ' reported by ' + results["countryforlegend"],'Trade reported by ' + (@controlpanel.reportertype == "I" ? "exporters " : "importers ")]
      data = (@controlpanel.reportertype == "I" ? [results["chartdata"]["Imports"],results["chartdata"]["Exports"]] : [results["chartdata"]["Exports"],results["chartdata"]["Imports"]])
      
      if (results["chartdata"]["Imports"].sum + results["chartdata"]["Exports"].sum) > 0
        @chart = Gchart.line(:size => '600x270',
                      #:title => "example title",
                      #:bg => 'efefef',
                      :legend => legend,
                      :data => data,
                      :encoding => 'text',
                      :max_value =>  results["datarange"][1],
                      :axis_with_labels => 'x,y' << ',y',
                      :axis_labels => [results["xaxislabels"],results["yaxislabels"],GroupTerm.term_description(@controlpanel.term)],
                      :bar_colors => ['003C30','80CDC1'],
                      :custom => 'chxtc=0,10|1,10&chxp=2,' + calculate_y_axis_midpoint(data,results["yaxislabels"].max),
                      :format => 'image_tag').to_s.gsub("%26","&").gsub("%3B",";")
      else
        @chart = "No data for this selection"
      end
      @reporttype = "Trade volume over time"
      @legend = (@controlpanel.reportertype == "I" ? " Imports " : " Exports ") +  " by " + @controlpanel.countrydescription
  end

    def generate_reexports
      sources =  NationalTradeSummary.reexports(@controlpanel.group,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'],@controlpanel.reportertype,@controlpanel.source,@controlpanel.country)
      if sources["data"].sum > 0  #i.e. we have data
        charttitle =  (@controlpanel.reportertype == "I" ? " Imports of re-exported " : " Re-exports of ")  + @controlpanel.group.downcase + " by " + @controlpanel.countrydescription
        @chart = get_bar_chart(sources,'vertical', 'chxtc=0,10|1,10|2,10', {:spacing => 10,:width => 40}, charttitle,'500x250')

        @mapdata = sources["mapdatastring"]
        @mapdataarray = sources["mapdataarray"]
      else
        @chart = "No data for this selection"
        @mapdata = "[]"
        @mapdataarray = []
      end

      @reporttype = "Re-exports"
      @legend = (@controlpanel.reportertype == "I" ? "Top ten re-exporters of " : "Top ten origin countries for re-exports of ") + @controlpanel.group.downcase + (@controlpanel.reportertype == "I" ? " to " : " from ") + @controlpanel.countrydescription
    end

  def load_species_distribution()
       @distribution = SpeciesDistribution.GetDistribution(@controlpanel.group,@controlpanel.class == NationalControlPanel ? @controlpanel.country : nil)
       @chart = ''
       @legend = @controlpanel.group + ', ' + @controlpanel.countrydescription
       @reporttype = "Species Occurrence"
       @mapdata = "[]"
       @mapdataarray = [] 
  end
end
