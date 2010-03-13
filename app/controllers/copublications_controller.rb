class CopublicationsController < ApplicationController
  caches_page :investigator_colleagues
  
  def show
    if params[:id].include?("search") then
      redirect_to :action => 'search'
    elsif params[:id].nil? || params[:id].include?("tag") then
      redirect_to abstracts_by_year_path(:id => @year, :page => '1')
    else
      @publication = Abstract.find(params[:id])
    end
  end
  
  def investigator_colleagues
    if params[:id] then
      @do_pagination = "0"
      @show_paginator=false
      @investigator_colleague = InvestigatorColleague.find(params[:id], :joins=>[:investigator,:colleague])
      @abstracts = @investigator_colleague.publications
      @total_entries=@abstracts.length
    end
  end
  
end
