class GraphvizController < ApplicationController

  caches_page( :show_member, :show_member_mesh, :show_org, :show_org_mesh) if CachePages()

  require 'graphviz_config'
  require 'csv_generator'
  require 'graph_generator'

  helper :all

  include GraphvizHelper
  include MeshHelper # for do_mesh_search

  def show_member
    @investigator = Investigator.find_by_username(params[:id])
     params[:analysis]="member"
    show_core
  end 

  def show_member_mesh
    @investigator = Investigator.find_by_username(params[:id])
    params[:analysis]="member_mesh"
    show_core
  end 

  def show_mesh
    mesh_terms = MeshHelper.do_mesh_search(params[:id])
    @name=mesh_terms.collect(&:name).join(', ')
    params[:analysis]="mesh"
    show_core
  end 

  def show_org
    @name = get_org_name(params[:id])
    params[:analysis]="org"
    show_core
   end 

   def show_org_org
     @name = get_org_name(params[:id])
     params[:analysis]="org_org"
     show_core
    end 

  def show_org_mesh
    @name = get_org_name(params[:id])
    params[:analysis]="org_mesh"
    show_core
  end 

  # use get_graphviz to convert to a proper REST call. default remote_function call is very hard to make RESTful
  def get_graphviz
    handle_graphviz_setup
    @file_name = build_graphviz_restfulpath(params, @output_format)
 #   @file_name = get_graph_dir("#{@graph_path}#{params[:program]}.#{@output_format}")
    
    render :layout=>false
  end

  def send_graphviz_image
    #send_graphviz/:id/:analysis/:distance/:stringency/:program.:format'
    handle_graphviz_setup
    @file_name = "public/#{@graph_path}#{params[:program]}.#{@output_format}"

    send_file @file_name, :type=> @content_type, :disposition => 'inline'
   end

  private  
  
  def handle_graphviz_setup
    # in 'graphviz_config'
    params[:program] ||= "neato"
    set_graphviz_defaults(params)
    # in the helper
    handle_graphviz_request()
    handle_graph_file()
  end
  
  
  def show_core
    params[:program] ||= "neato"
    set_graphviz_defaults(params)
    
    params[:format] =  nil
    if !params[:id].blank? then
       respond_to do |format|
        format.html { render }
      end
    else 
      redirect_to show_org_graph_path(1)
    end 
  end 
   
  def get_org_name(id)
    # logger.info "id: #{id}"
    ids=id.split(",")
    if ids.length > 1
      OrganizationalUnit.find(:all, :conditions => ["id in (:ids)", {:ids=>ids }]).collect(&:name).join(", ")
    else
      OrganizationalUnit.find(id).name
    end
  end
  
  def get_orgs(id)
    ids=id.split(",")
    if ids.length > 1
      OrganizationalUnit.find(:all, :conditions => ["id in (:ids)", {:ids=>ids }])
    else
      OrganizationalUnit.find_all_by_id(id)
    end
  end
  
  def get_colleagues(id)
    ids=id.split(",")
    if ids.length > 1
      orgs = OrganizationalUnit.find(:all, :conditions => ["id in (:ids)", {:ids=>ids }])
      colleagues=orgs.collect{|org| org.all_faculty }.flatten.uniq
      #orgs.collect{ |org| org.primary_faculty.full_time.investigator}.flatten
    else
      org = OrganizationalUnit.find(id)
      colleagues = org.all_faculty
    end
  end
  
end