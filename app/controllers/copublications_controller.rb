class CopublicationsController < ApplicationController
  caches_page( :investigator_colleagues, :tag_cloud_side, :tag_cloud) if LatticeGridHelper.CachePages()
  
  include ApplicationHelper
  
  def show
    if params[:id].include?("search") then
      redirect_to :action => 'search'
    elsif params[:id].nil? || params[:id].include?("tag") then
      redirect_to abstracts_by_year_url(:id => @year, :page => '1')
    else
      @publication = Abstract.find(params[:id])
    end
  end
  
  def investigator_colleagues
    if params[:id] then
      @do_pagination = "0"
      @show_paginator=false
      @investigator_colleague = InvestigatorColleague.find(params[:id], :joins=>[:investigator,:colleague])
      #@abstracts = @investigator_colleague.publications
      @abstracts = @investigator_colleague.investigator.shared_abstracts_with_investigator(@investigator_colleague.colleague.id)
      @total_entries=@abstracts.length
    end
  end
  
  def tag_cloud_side
    investigator_colleague = InvestigatorColleague.find(params[:id], :joins=>[:investigator,:colleague])
    tags = investigator_colleague.investigator.tag_counts(:limit => 40, :order => "count desc") & investigator_colleague.colleague.tag_counts(:limit => 40, :order => "count desc")
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags, :update_id => 'tag_cloud_side', :include_breaks => true} }
    end
  end 
  
  def tag_cloud
    investigator_colleague = InvestigatorColleague.find(params[:id], :joins=>[:investigator,:colleague])
    tags = investigator_colleague.investigator.tag_counts(:order => "count desc") & investigator_colleague.colleague.tag_counts(:order => "count desc")
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags}  }
    end
  end 
  
  
end
