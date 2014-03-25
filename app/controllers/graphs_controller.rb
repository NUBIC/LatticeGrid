# -*- coding: utf-8 -*-

##
# Controller for many visualizations
class GraphsController < ApplicationController
  caches_page(:show_org, :show_member, :member_nodes, :org_nodes) if LatticeGridHelper.cache_pages?

  include ApplicationHelper

  def index
    redirect_to show_org_graph_url(1)
  end

  def show_org
    redirect_to show_org_graph_url(1) if params[:id].blank?
  end

  def show_member
    if params[:id].blank?
      redirect_to show_org_graph_url(1)
    else
      # reassemble the username if necessary
      params[:id] = params[:id] + '.' + params[:format] unless params[:format].blank?
      @investigator = Investigator.find_by_username(params[:id])
    end
  end

  def member_nodes
    if params[:id].blank?
      xml = "<chart><set label='invalid data' value='10' link='/abstracts/2009/year_list' toolText='Invalid Data' /><set label='id was nil' value='11' /></chart>"
      headers['Content-Type'] = 'text/xml'
      render text: xml, layout: false
    else
      clause = 'investigators.username = :username AND ' +
               ' (investigator_appointments.end_date is null OR investigator_appointments.end_date >= :now)'
      @investigator = Investigator.includes(['investigator_appointments'])
                                  .where(clause, { now: Date.today, username: params[:id] })
                                  .first
      Investigator.get_investigator_connections(@investigator, 25)
      @heading = "Interaction graph for Investigator #{@investigator.first_name} #{@investigator.last_name}"
      request.format = 'xml'
      respond_to do |format|
        format.xml
      end
    end
  end

  def org_nodes
    params[:id] = 1 if params[:id].blank?
    @unit = OrganizationalUnit.find(params[:id])
    @investigators = (@unit.primary_faculty + @unit.associated_faculty).uniq
    Investigator.get_connections(@investigators, 25)
    @heading = "Faculty graph for '#{@unit.name}'"
    request.format = 'xml'
    respond_to do |format|
      format.xml
    end
  end
end
