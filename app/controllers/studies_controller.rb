class StudiesController < ApplicationController
  include InvestigatorsHelper
  include StudiesHelper
  include FormatHelper
  include ApplicationHelper
  require 'cytoscape_generator'

  before_filter :check_allowed, :except => [:disallowed]
  caches_action( :listing, :investigator, :show )  if LatticeGridHelper.CachePages()
  
  def show
    if params[:id].nil? then
      redirect_to( current_abstracts_url)
    else
      if params[:id] =~ /^\d+$/
        @study = Study.find_by_id(params[:id])
      else
        @study = Study.find_by_irb_study_number(params[:id])
      end
        
      respond_to do |format|
        format.html { 
        	render
        }
      end
    end
  end

  def investigator
    @javascripts_add = ['jquery-ui.min']
    @stylesheets = [ 'publications', "latticegrid/#{lattice_grid_instance}", 'jquery-ui' ]
    if params[:id].nil? then
      redirect_to( current_abstracts_url)
    else
      handle_member_name(false)  #sets @investigator
      @pi_studies = @investigator.investigator_studies.by_role
      respond_to do |format|
        format.html { 
        	render
        }
        format.xml  { 
           render :xml => @investigator.proposals }
        format.xls  { 
          @pdf = 1
           send_data(render(:template => 'studies/investigator.html', :layout => "excel"),
          :filename => "study_listing_for_#{@investigator.first_name}_#{@investigator.last_name}.xls",
          :type => 'application/vnd.ms-excel',
          :disposition => 'attachment') }
        format.doc  { 
          @pdf = 1
          send_data(render(:template => 'studies/investigator.html', :layout => "excel"),
          :filename => "study_listing_for_#{@investigator.first_name}_#{@investigator.last_name}.doc",
          :type => 'application/msword',
          :disposition => 'attachment') }
        format.pdf do
          @pdf = 1
          render( :pdf => "Study listing for " + @investigator.name, 
              :stylesheets => "pdf", 
              :template => "studies/investigator.html",
              :layout => "pdf")
        end
      end
    end
  end

  def listing
    @javascripts_add = ['jquery.min', 'jquery.tablesorter.min', 'jquery.fixheadertable.min']
    @investigators = Investigator.all(:conditions=>"total_studies > 0", :order=> "total_studies desc")
    @css =  "#main {width:1500px;}"
    respond_to do |format|
      format.html { render :layout => 'printable'}
      format.xml  { render :xml => @investigators }
      format.pdf do
        @pdf = true
        render( :pdf => "Investigator Study Listing", 
            :stylesheets => "pdf", 
            :template => "studies/listing.html",
            :layout => "pdf")
      end
    end
  end

  private
  
  def check_allowed
    unless allowed_ip(get_client_ip()) then 
      redirect_to disallowed_awards_url
    end
  end

end
