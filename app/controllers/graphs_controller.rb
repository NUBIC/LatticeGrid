class GraphsController < ApplicationController
  caches_page( :show_org, :show_member, :member_nodes, :org_nodes) if CachePages()
  
  def index
    redirect_to show_org_graph_path(1)
  end

  def show_org
    if params[:id].blank? then
      redirect_to show_org_graph_path(1)
    end
  end

  def show_member
   if !params[:id].blank? then
     if !params[:format].blank? then #reassemble the username
       params[:id]=params[:id]+'.'+params[:format]
     end
   else 
     redirect_to show_org_graph_path(1)
   end 
  end 

  def member_nodes
    if !params[:id].blank? then
     @investigator = Investigator.find( :first,
        :include => ['investigator_appointments'],
        :conditions => ['investigators.username = :username',
           {:username => params[:id]}] )
     Investigator.get_investigator_connections(@investigator, 25)

     @heading = "Interaction graph for Investigator #{@investigator.first_name} #{@investigator.last_name}"
     respond_to do |format|
       format.xml
     end
   else 
     strXML = "<chart><set label='invalid data' value='10' link='/abstracts/2009/year_list' toolText='Invalid Data' /><set label='id was nil' value='11' /></chart>"
     headers['Content-Type'] = 'text/xml'
     render :text=> strXML, :layout=>false
   end 
  end

  def org_nodes
    params[:id] = 1 if params[:id].blank?
    @unit = OrganizationalUnit.find(params[:id])
    @investigators = (@unit.primary_faculty+@unit.associated_faculty).uniq
    Investigator.get_connections(@investigators,25)
    @heading = "Faculty graph for '#{@unit.name}'"
    respond_to do |format|
      format.xml
    end
  end
end
