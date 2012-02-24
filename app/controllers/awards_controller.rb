class AwardsController < ApplicationController
  include InvestigatorsHelper
  include AwardsHelper
  include FormatHelper
  include ApplicationHelper
  include OrgsHelper
  
  require 'cytoscape_generator'

  before_filter :check_allowed, :except => [:disallowed]
  caches_action( :listing, :investigator, :show )  if LatticeGridHelper.CachePages()
  
  def show 
    if params[:id].nil? then
      redirect_to( current_abstracts_url)
    else
      if params[:id] =~ /^\d+$/
        @award = Proposal.find_by_id(params[:id])
      else
        @award = Proposal.find_by_institution_award_number(params[:id])
      end
      respond_to do |format|
        format.html { 
        	render
        }
      end
    end
  end 
  
  def listing
    @javascripts_add = ['jquery.min', 'jquery.tablesorter.min', 'jquery.fixheadertable.min']
    @investigators = Investigator.proposal_totals()
    @css =  "#main {width:1900px;}"
    respond_to do |format|
      format.html { render :layout => 'printable'}
      format.xml  { render :xml => @investigators }
      format.pdf do
        @pdf = true
        render( :pdf => "Investigator Awards Listing", 
            :stylesheets => "pdf", 
            :template => "awards/listing.html",
            :layout => "pdf")
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
      @pi_awards = @investigator.investigator_proposals.by_role
      respond_to do |format|
        format.html { 
        	render
        }
        format.xml  { 
           render :xml => @investigator.proposals }
        format.xls  { 
          @pdf = 1
           send_data(render(:template => 'awards/investigator.html', :layout => "excel"),
          :filename => "award_listing_for_#{@investigator.first_name}_#{@investigator.last_name}.xls",
          :type => 'application/vnd.ms-excel',
          :disposition => 'attachment') }
        format.doc  { 
          @pdf = 1
          send_data(render(:template => 'awards/investigator.html', :layout => "excel"),
          :filename => "award_listing_for_#{@investigator.first_name}_#{@investigator.last_name}.doc",
          :type => 'application/msword',
          :disposition => 'attachment') }
        format.pdf do
          @pdf = 1
          render( :pdf => "Award listing for " + @investigator.name, 
              :stylesheets => "pdf", 
              :template => "awards/investigator.html",
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
       @awards = Proposal.belonging_to_pi_ids(@investigator_ids)
       previous = nil
       @awards_total = @awards.map{ |a| 
          val = (previous.blank? or previous != a.id ) ? a.total_amount : 0 
          previous = a.id
          val}.inject(0){|sum, element| sum+element}
       respond_to do |format|
         format.html { 
         	render
         }
         format.xml  { 
            render :xml => @investigator.proposals }
         format.xls  { 
           @pdf = 1
            send_data(render(:template => 'awards/org.html', :layout => "excel"),
           :filename => "award_listing_for_#{@unit.name}.xls",
           :type => 'application/vnd.ms-excel',
           :disposition => 'attachment') }
         format.doc  { 
           @pdf = 1
           send_data(render(:template => 'awards/org.html', :layout => "excel"),
           :filename => "award_listing_for_#{@unit.name}.doc",
           :type => 'application/msword',
           :disposition => 'attachment') }
         format.pdf do
           @pdf = 1
           render( :pdf => "Award listing for " + @unit.name, 
               :stylesheets => "pdf", 
               :template => "awards/org.html",
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
