class GlobalController < SharedController
  def index
    if params[:id] == nil and session[:controlpanel] != nil and session[:controlpanel].class == GlobalControlPanel
      @controlpanel = session[:controlpanel]
    else
      @controlpanel = GlobalControlPanel.new({:group=> params[:id] != nil ? params[:id] : "Mammals",
                                              :date_range=>GlobalTradeSummary.maxdate,
                                              :term=>GroupTerm.default(params[:id] != nil ? params[:id] : "Mammals"),
                                              :source=>'All',
                                              :display=>"Time",
                                              :reportertype => "I"})
    end
  #rescue
  #  render :text => "Sorry, an error has occurred while processing your request"
  end

  def load_chart
    @controlpanel = GlobalControlPanel.new(params[:controlpanel])
    if session[:group] != @controlpanel.group
      @controlpanel.term = GroupTerm.default(@controlpanel.group)
    end
    generate_chart
    render :template => 'shared/load_chart'
  end

private
  def  generate_chart
    case @controlpanel.display
      when "Importers"
        generate_top_10_partner("I")
      when "Exporters"
        generate_top_10_partner("E")
      when "Terms"
        generate_top_5_term
      #when "Sources"
      #  generate_sources
      when "Time"
        generate_trade_over_time
      when "Appendix"
        generate_appendix
      when "Species"
        generate_top_10_species
      when "Families"
        generate_top_10_families
      when "Sources"
        generate_sources
    end
  end

  def generate_trade_over_time
    results =  SharedTradeSummary.trade_over_time(@controlpanel.group,@controlpanel.source,@controlpanel.term,@controlpanel.dateendpoints['startdate'],@controlpanel.dateendpoints['enddate'])
    if (results["chartdata"]["Imports"].sum + results["chartdata"]["Exports"].sum) > 0
      @chart = Gchart.line(:size => '600x270',
                        #:title => "example title",
                        #:bg => 'efefef',
                        :legend => ['Trade reported by importers', 'Trade reported by exporters'],
                        :data => [results["chartdata"]["Imports"],results["chartdata"]["Exports"]],
                        :encoding => 'text',
                        :max_value =>  results["yaxislabels"][1],
                        :axis_with_labels => 'x,y' << ',y',
                        :axis_labels => [results["xaxislabels"],results["yaxislabels"],GroupTerm.term_description(@controlpanel.term)],
                        :bar_colors => ['003C30','80CDC1'],
                        :custom => 'chxtc=0,10|1,10&chxp=2,' + calculate_y_axis_midpoint([results["chartdata"]["Imports"],results["chartdata"]["Exports"]],results["yaxislabels"].max),
                        :max_value =>  results["datarange"][1],
                        :format => 'image_tag').to_s.gsub("%26","&").gsub("%3B",";")
      else
        @chart = "No data for this selection"
    end
        @reporttype = "Trade volume over time"
        @legend = ''
  end

end
