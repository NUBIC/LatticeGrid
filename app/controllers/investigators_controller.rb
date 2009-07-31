class InvestigatorsController < ApplicationController
  caches_page :show, :full_show
  helper :sparklines
  
  def index
    redirect_to( year_list_abstracts_url )
  end
  def list_all
    @investigators = Investigator.find(:all, :include=>[:programs], :conditions => ['investigators.end_date is null or investigators.end_date >= :now', {:now => Date.today }], :order => "last_name, first_name")   
    render :layout => 'printable'
  end
  def full_show
    if params[:id].nil? then
      redirect_to( year_list_abstracts_url )
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
      redirect_to( year_list_abstracts_url)
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
  def tag_cloud_side
    @tags = Investigator.find(params[:id]).abstracts.tag_counts(:limit => 15, :order => "count desc")
  end 
  def tag_cloud
    @tags = Investigator.find(params[:id]).abstracts.tag_counts( :order => "count desc")
  end 
end
