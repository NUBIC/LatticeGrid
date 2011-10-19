class InvestigatorsController < ApplicationController
  caches_page( :show, :full_show, :list_all, :listing, :tag_cloud_side, :tag_cloud, :show_all_tags, :publications, :tag_cloud_list, :abstract_count, :preview, :search) if LatticeGridHelper.CachePages()
  helper :all
  include InvestigatorsHelper
  include ApplicationHelper

  require 'pubmed_utilities'

  skip_before_filter  :find_last_load_date, :only => [:tag_cloud_side, :tag_cloud, :search]
  skip_before_filter  :handle_year, :only => [:tag_cloud_side, :tag_cloud, :search]
  skip_before_filter  :get_organizations, :only => [:tag_cloud_side, :tag_cloud, :search]
  skip_before_filter  :handle_pagination, :only => [:tag_cloud_side, :tag_cloud, :search]
  skip_before_filter  :define_keywords, :only => [:tag_cloud_side, :tag_cloud, :search]
  
  def index
    redirect_to( current_abstracts_url )
  end
  
  def list_all
    @investigators = Investigator.all(:include=>[:home_department,:appointments], :order => "last_name, first_name")   
    respond_to do |format|
      format.html { render :layout => 'printable'}
      format.xml  { render :xml => @units }
      format.pdf do
        @pdf = true
        render( :pdf => "Investigator Listing", 
            :stylesheets => "pdf", 
            :template => "investigators/list_all.html",
            :layout => "pdf")
      end
    end
  end
  
  def list_by_ids
    if params[:investigator_ids].nil? then
      redirect_to( year_list_abstracts_url )
    else
      @investigators = Investigator.find_investigators_in_list(params[:investigator_ids]).sort{|x,y| x.last_name+x.first_name <=> y.last_name+y.first_name}
      respond_to do |format|
        format.html { render :action => 'list_all', :layout => 'printable'}
        format.xml  { render :xml => @investigators }
        format.pdf do
          @pdf = true
          render( :pdf => "Investigator Listing", 
              :stylesheets => "pdf", 
              :template => "investigators/list_all.html",
              :layout => "pdf")
        end
        format.xls  { send_data(render(:template => 'investigators/list_all.html', :layout => "excel"),
          :filename => "Investigator Listing.xls",
          :type => 'application/vnd.ms-excel',
          :disposition => 'attachment') }
        format.doc  { send_data(render(:template => 'investigators/list_all.html', :layout => "excel"),
          :filename => "Investigator Listing.doc",
          :type => 'application/msword',
          :disposition => 'attachment') }
        
      end
    end
  end
  
  def listing
    @javascripts_add = ['jquery.min', 'jquery.tablesorter.min', 'jquery.fixheadertable.min']
    @investigators = Investigator.all( :conditions=>['total_publications > 2'], :order => "total_publications desc", :limit => 3000 )   
    respond_to do |format|
      format.html { render :layout => 'printable'}
      format.xml  { render :xml => @investigators }
      format.pdf do
        @pdf = true
        render( :pdf => "Investigator Listing", 
            :stylesheets => "pdf", 
            :template => "investigators/listing.html",
            :layout => "pdf")
      end
    end
  end
  
  
  def full_show
    if params[:id].nil? then
      redirect_to( year_list_abstracts_url )
    elsif !params[:page].nil? then
      params.delete(:page)
      redirect_to params
    else
      handle_member_name # converts params[:id] to params[:investigator_id] and sets @investigator
      @do_pagination = "0"
      @heading = "Selected publications from 2004-2011" if LatticeGridHelper.GetDefaultSchool() == 'UMDNJ'
      @abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
      @all_abstracts=@abstracts
      @total_entries=@abstracts.length
      respond_to do |format|
        format.html { render :action => 'show' }
        format.xml  { render :layout => false, :xml  => @abstracts.to_xml() }
      end
    end
  end
  
  def publications
    # set variables used in show
    handle_member_name # sets @investigator
    @do_pagination = "0"
    @abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
    @all_abstracts=@abstracts
    @total_entries=@abstracts.length

    respond_to do |format|
      format.html { render :action => 'show' }
      format.json do
        render :layout => false, :json => @abstracts.to_json() 
      end
      format.xml  { render :layout => false, :xml  => @abstracts.to_xml() }
    end
    
  end
  
  def abstract_count
    # set variables used in show
    handle_member_name(false) # sets @investigator
    investigator = @investigator
    abstract_count = 0
    tags = ""
    if !investigator.nil?
      abstract_count = investigator.abstracts.length 
      tags = investigator.tags.collect(&:name).join(', ')
    end
    respond_to do |format|
      format.html { render :text => "abstract count = #{abstract_count},  tags = #{tags}, investigator_id = #{params[:investigator_id]}" }
      format.json { render :layout => false, :json => {"abstract_count" => abstract_count, "tags" => tags, "investigator_id" => params[:investigator_id] }.as_json() }
      format.xml  { render :layout => false, :xml  => {"abstract_count" => abstract_count, "tags" => tags, "investigator_id" => params[:investigator_id]}.to_xml() }
    end
    
  end
  
  def show 
    if params[:id].nil? then
      redirect_to( year_list_abstracts_url)
    elsif params[:page].nil? then
      params[:page]="1"
      redirect_to params
    else
      handle_member_name # sets @investigator
      @heading = "Selected publications from 2004-2011" if LatticeGridHelper.GetDefaultSchool() == 'UMDNJ'
      @do_pagination = "1"
      @abstracts = Abstract.display_investigator_data(params[:investigator_id],params[:page] )
      @all_abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
      @include_pubmed_id = true unless params[:include_pubmed_id].blank?
      @total_entries=@abstracts.total_entries
    end
  end 
  
  def show_all_tags
    if params[:id].nil? then
      redirect_to( year_list_abstracts_url)
    elsif params[:page].nil? then
      params[:page]="1"
      redirect_to params
    else
      handle_member_name # sets @investigator
      @do_pagination = "1"
      @abstracts = Abstract.display_investigator_data(params[:investigator_id],params[:page] )
      @all_abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
      @total_entries=@abstracts.total_entries
      @include_all_mesh = true
      respond_to do |format|
        format.html { render :action => :show}
      end
    end
  end 

  def tag_cloud_side
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    tags = investigator.abstracts.tag_counts(:limit => 15, :order => "count desc")
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags, :investigator => investigator}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags, :investigator => investigator, :update_id => 'tag_cloud_side', :include_breaks => true} }
    end
  end 
  def tag_cloud
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    respond_to do |format|
      format.html { 
        tags = investigator.abstracts.map{|ab| ab.tags.map(&:name) }.flatten
        render :text => tags.join(", ")
      }
      format.js  { 
        tags = investigator.abstracts.tag_counts( :order => "count desc")
        render  :partial => "shared/tag_cloud", :locals => {:tags => tags}  
      }
    end
  end 
  
  def research_summary
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    summary = investigator.investigator_appointments.map(&:research_summary).join("; ")
    summary = investigator.faculty_research_summary if summary.blank?
    respond_to do |format|
      format.html { render :text => summary }
      format.js  { render :json => summary.to_json  }
      format.json  { render :json => summary.to_json  }
    end
  end 

  def title
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    title = investigator.title
    respond_to do |format|
      format.html { render :text => title }
      format.js  { render :json => title.to_json  }
      format.json  { render :json => title.to_json  }
    end
  end 

  def email
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    email = investigator.email
    respond_to do |format|
      format.html { render :text => email }
      format.js  { render :json => email.to_json  }
      format.json  { render :json => email.to_json  }
    end
  end 

  def home_department
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    home_department_name = investigator.home_department_name
    respond_to do |format|
      format.html { render :text => home_department_name }
      format.js  { render :json => home_department_name.to_json  }
      format.json  { render :json => home_department_name.to_json  }
    end
  end 

  def affiliations
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    affiliations = []
    investigator.appointments.each { |appt| affiliations << [appt.name, appt.division_id, appt.id] }
    respond_to do |format|
      format.html { render :text => affiliations.join("; ") }
      format.js  { render :json => affiliations.to_json  }
      format.json  { render :json => affiliations.to_json  }
    end
  end 

  def bio
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    summary = investigator.investigator_appointments.map(&:research_summary).join("; ")
    summary = investigator.faculty_research_summary if summary.blank?
    affiliations = []
    investigator.appointments.each { |appt| affiliations << [appt.name, appt.division_id, appt.id] }
    respond_to do |format|
      format.html { render :text => summary }
      format.js { render :json => {"name" => investigator.full_name, "title" => investigator.title, "publications_count" => investigator.total_publications, "home_department" => investigator.home_department_name, "research_summary" => summary, "email" => investigator.email, "affiliations" => affiliations }.as_json() }
      format.json { render :json => {"name" => investigator.full_name, "title" => investigator.title, "publications_count" => investigator.total_publications, "home_department" => investigator.home_department_name, "research_summary" => summary, "email" => investigator.email, "affiliations" => affiliations }.as_json() }
    end
  end 
  
  #:title => :get, :bio=>:get, :email=>:get, :affiliations=>:get
  
  
  # Differs from above because the Investigator is found by username instead of id
  # Then it will send a json response to the requester
  def tag_cloud_list
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    result = []
    tags = investigator.abstracts.tag_counts(:limit => 15, :order => "count desc")
    tags.each { |tag| result << [tag.name, tag.count] }
    render :json => result.to_json
  end
  
  def investigators_search 
    if params[:id].blank? and !params[:keywords].blank?
      params[:id] = params[:keywords]
    end
    if !params[:id].blank? then
      @investigators = Investigator.investigators_tsearch(params[:id])
      @heading = "There were #{@investigators.length} matches to search term <i>"+params[:id].downcase+"</i>"
      @include_mesh=false
      render :action => :index, :layout => "searchable"
    else 
      logger.error "search did not have a defined keyword"
      year_list  # includes a render
    end 
   end
  
  
  def search 
    if params[:id].blank? and !params[:keywords].blank?
      params[:id] = params[:keywords]
    end
    if !params[:id].blank? then
      @investigators = Investigator.all_tsearch(params[:id])
      @heading = "There were #{@investigators.length} matches to search term <i>"+params[:id].downcase+"</i>"
      @include_mesh=false
      render :action => :index, :layout => "searchable"
    else 
      logger.error "search did not have a defined keyword"
      year_list  # includes a render
    end 
   end
  
   def preview 
     if !params[:id].blank? then
       @investigators = Investigator.top_ten_tsearch(params[:id])
       render :action => :preview, :layout => "preview"
     else 
       logger.error "search did not have a defined keyword"
       year_list  # includes a render
     end 
    end

   def direct_search 
     logger.error "direct_search called with #{params[:id]}"
     if !params[:id].blank? then
       @search_length = Investigator.count_all_tsearch(params[:id])
     else 
       logger.error "search did not have a defined keyword"
       @search_length=0
     end 
     render :layout => false, :template => 'investigators/direct_search.xml'  # direct_search.xml.builder 
     logger.error "direct_search completed with #{params[:id]}"
   end
   
  private

end
