class GraphsController < ApplicationController
  caches_page :show_program, :show_member, :member_nodes, :program_nodes
  
  def index
    redirect_to show_program_graph_url(1)
  end

  def show_program
    if params[:id].blank? then
      redirect_to show_program_graph_url(1)
    end
  end

  def show_member
   if !params[:id].blank? then
     if !params[:format].blank? then #reassemble the username
       params[:id]=params[:id]+'.'+params[:format]
     end
   else 
     redirect_to show_program_graph_url(1)
   end 
  end 

  def member_nodes
    if !params[:id].blank? then
     @investigator = Investigator.find( :first,
        :include => ['investigator_programs'],
        :conditions => ['investigators.username = :username',
           {:username => params[:id]}] )
     Investigator.get_investigator_connections(@investigator)

     @heading = "Interaction graph for Investigator #{@investigator.first_name} #{@investigator.last_name}"
     respond_to do |format|
       format.xml
     end
   else 
     strXML = "<chart><set label='invalid data' value='10' link='/abstracts/program_listing?program_id=2' toolText='Invalid Data' /><set label='id was nil' value='11' /></chart>"
     headers['Content-Type'] = 'text/xml'
     render :text=> strXML, :layout=>false
   end 
  end

   def program_nodes
     params[:id] = 1 if params[:id].blank?
     @program = Program.find(params[:id])
     @investigators = Investigator.find :all, 
        :order => 'last_name ASC, first_name ASC',
        :joins => [:programs],
        :conditions => ['programs.id = :program_id',
          {:program_id => params[:id]}]
    Investigator.get_connections(@investigators)

    @heading = "Faculty graph for '#{@program.program_title}'"
       respond_to do |format|
        format.xml
      end
   end
end
