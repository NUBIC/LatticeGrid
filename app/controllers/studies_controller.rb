class StudiesController < ApplicationController
  include InvestigatorsHelper
  include StudiesHelper
  include FormatHelper
  include ApplicationHelper
  require 'cytoscape_generator'
  include OrgsHelper

  before_filter :check_allowed, :except => [:disallowed]
  caches_action( :listing, :investigator, :show, :org )  if LatticeGridHelper.CachePages()
  
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

  def org 
    @javascripts_add = ['jquery-ui.min']
    @stylesheets = [ 'publications', "latticegrid/#{lattice_grid_instance}", 'jquery-ui' ]
    if params[:id].nil? then
      redirect_to( current_abstracts_url)
    else
      @unit = find_unit_by_id_or_name(params[:id])
      @investigators = @unit.all_primary_or_member_faculty
      @investigator_ids = @investigators.map(&:id)
      @studies = Study.belonging_to_pi_ids(@investigator_ids)
      respond_to do |format|
        format.html { 
        	render
        }
        format.xml  { 
           render :xml => @studies }
        format.xls  { 
          @pdf = 1
           send_data(render(:template => 'studies/org.html', :layout => "excel"),
          :filename => "study_listing_for_#{@unit.name}.xls",
          :type => 'application/vnd.ms-excel',
          :disposition => 'attachment') }
        format.doc  { 
          @pdf = 1
          send_data(render(:template => 'studies/org.html', :layout => "excel"),
          :filename => "study_listing_for_#{@unit.name}.doc",
          :type => 'application/msword',
          :disposition => 'attachment') }
        format.pdf do
          @pdf = 1
          render( :pdf => "Study listing for " + @unit.name, 
              :stylesheets => "pdf", 
              :template => "studies/org.html",
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
  
  def ad_hoc_by_pi 
    if params[:start_date].nil? or params[:end_date].nil? then
      redirect_to( current_abstracts_url)
    else
      @javascripts_add = ['jquery.min', 'jquery.tablesorter.min', 'jquery.fixheadertable.min', 'jquery-ui.min']
      @stylesheets = [ 'publications', "latticegrid/#{lattice_grid_instance}", 'jquery-ui' ]
      
      @faculty = Investigator.find_investigators_in_list(params[:investigator_ids]).sort{|x,y| x.last_name+' '+x.first_name <=> y.last_name+' '+y.first_name}
      @investigators_in_unit = @faculty.map(&:id).sort.uniq
       
      @studies = Study.recents_by_pi(@investigators_in_unit, params[:start_date], params[:end_date])
 
      @css =  "#main {width:1900px;}"
      @title = "Research studies active between #{params[:start_date]} and #{params[:end_date]}"
       
      respond_to do |format|
        format.html { render :action => :org, :layout => 'printable' }
        format.xml  { render :xml => @studies }
        format.xls  { 
          @pdf = 1
           send_data(render(:template => 'studies/org.html', :layout => "excel"),
          :filename => "adhoc_study_listing.xls",
          :type => 'application/vnd.ms-excel',
          :disposition => 'attachment') }
        format.doc  { 
          @pdf = 1
          send_data(render(:template => 'studies/org.html', :layout => "excel"),
          :filename => "adhoc_study_listing.doc",
          :type => 'application/msword',
          :disposition => 'attachment') }
        format.pdf do
          @pdf = 1
          render( :pdf => "Study listing for " + @unit.name, 
              :stylesheets => "pdf", 
              :template => "studies/org.html",
              :layout => "pdf")
        end
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
