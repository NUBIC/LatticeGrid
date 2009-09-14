class InvestigatorsController < ApplicationController
  caches_page :show, :full_show, :list_all, :tag_cloud_side, :tag_cloud, :show_all_tags
  helper :sparklines
  require 'ldap_utilities' #specific ldap methods

  skip_before_filter  :find_last_load_date, :only => [:tag_cloud_side, :tag_cloud]
  skip_before_filter  :handle_year, :only => [:tag_cloud_side, :tag_cloud]
  skip_before_filter  :get_organizations, :only => [:tag_cloud_side, :tag_cloud]
  skip_before_filter  :handle_pagination, :only => [:tag_cloud_side, :tag_cloud]
  skip_before_filter  :define_keywords, :only => [:tag_cloud_side, :tag_cloud]
  
  def index
    redirect_to( year_list_abstracts_path )
  end
  def list_all
    @investigators = Investigator.find(:all, :include=>[:home_department,:appointments], :conditions => ['investigators.end_date is null or investigators.end_date >= :now', {:now => Date.today }], :order => "last_name, first_name")   
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
      handle_member_name
      @do_pagination = "0"
      @abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
      @all_abstracts=@abstracts
      @total_entries=@abstracts.length
      render :action => 'show'
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
    investigator = Investigator.find(params[:id])
    tags = investigator.abstracts.tag_counts(:limit => 15, :order => "count desc")
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags, :investigator => investigator}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags, :investigator => investigator, :update_id => 'tag_cloud_side', :include_breaks => true} }
    end
  end 
  def tag_cloud
    investigator = Investigator.find(params[:id])
    tags = investigator.abstracts.tag_counts( :order => "count desc")
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags}  }
    end
  end 

  private
  def handle_member_name
    return if params[:id].blank?
    if !params[:format].blank? then #reassemble the username
      params[:id]=params[:id]+"."+params[:format]
    end
    if params[:name].blank? then
      @investigator = Investigator.find_by_username(params[:id])
      if @investigator
        params[:investigator_id] = @investigator.id
        params[:name] =  @investigator.first_name + " " + @investigator.last_name
        begin
          pi_data = GetLDAPentry(@investigator.username)
          if pi_data.nil?
            logger.warn("Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null for #{params[:name]} using netid #{@investigator.username}.")
          else
            ldap_rec=CleanPIfromLDAP(pi_data)
            @investigator=MergePIrecords(@investigator,ldap_rec)
          end
         rescue Exception => error
          logger.error("Probable error reaching the LDAP server in GetLDAPentry: #{error.message}")
        end
       else
        logger.error("Attempt to access invalid username (netid) #{params[:id]}") 
        flash[:notice] = "Sorry - invalid username <i>#{params[:id]}</i>"
        params.delete(:id)
      end
    end
  end

end
