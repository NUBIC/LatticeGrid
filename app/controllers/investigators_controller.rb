class InvestigatorsController < ApplicationController
  caches_page( :show, :full_show, :list_all, :tag_cloud_side, :tag_cloud, :show_all_tags) if CachePages()
  helper :all
  include InvestigatorsHelper

  skip_before_filter  :find_last_load_date, :only => [:tag_cloud_side, :tag_cloud]
  skip_before_filter  :handle_year, :only => [:tag_cloud_side, :tag_cloud]
  skip_before_filter  :get_organizations, :only => [:tag_cloud_side, :tag_cloud]
  skip_before_filter  :handle_pagination, :only => [:tag_cloud_side, :tag_cloud]
  skip_before_filter  :define_keywords, :only => [:tag_cloud_side, :tag_cloud]
  
  def index
    redirect_to( current_abstracts_path )
  end
  def list_all
    @investigators = Investigator.find(:all, :include=>[:home_department,:appointments], :order => "last_name, first_name")   
    respond_to do |format|
      format.html { render :layout => 'printable'}
      format.xml  { render :xml => @units }
    end
    
  end
  def full_show
    if params[:id].nil? then
      redirect_to( year_list_abstracts_path )
    elsif !params[:page].nil? then
      params.delete(:page)
      redirect_to params
    else
      handle_member_name # converts params[:id] to params[:investigator_id]
      @do_pagination = "0"
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
    @investigator = Investigator.find_by_username(params[:id])
    @do_pagination = "0"
    @abstracts = Abstract.display_all_investigator_data(@investigator.id)
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
  
  def show 
    if params[:id].nil? then
      redirect_to( year_list_abstracts_path)
    elsif params[:page].nil? then
      params[:page]="1"
      redirect_to params
    else
      handle_member_name
      @do_pagination = "1"
      @abstracts = Abstract.display_investigator_data(params[:investigator_id],params[:page] )
      @all_abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
      @include_pubmed_id = true unless params[:include_pubmed_id].blank?
      @total_entries=@abstracts.total_entries
    end
  end 
  
  def show_all_tags
    if params[:id].nil? then
      redirect_to( year_list_abstracts_path)
    elsif params[:page].nil? then
      params[:page]="1"
      redirect_to params
    else
      handle_member_name
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
    investigator = Investigator.include_deleted(params[:id])
    tags = investigator.abstracts.tag_counts(:limit => 15, :order => "count desc")
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags, :investigator => investigator}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags, :investigator => investigator, :update_id => 'tag_cloud_side', :include_breaks => true} }
    end
  end 
  def tag_cloud
    investigator = Investigator.include_deleted(params[:id])
    tags = investigator.abstracts.tag_counts( :order => "count desc")
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags}  }
    end
  end 
  
  # Differs from above because the Investigator is found by username instead of id
  # Then it will send a json response to the requester
  def tag_cloud_list
    investigator = Investigator.find_by_username_including_deleted(params[:username])
    result = []
    tags = investigator.abstracts.tag_counts(:limit => 15, :order => "count desc")
    tags.each { |tag| result << [tag.name, tag.count] }
    render :json => result.to_json
  end

  private

end
