class GraphvizController < ApplicationController

  caches_page( :show_member, :show_member_mesh, :show_org, :show_org_mesh) if CachePages()

  # GET /admins
  # GET /admins.xml
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
    id=params[:id]
    if  id.to_i.to_s == id
      mesh_terms = Tag.find_all_by_id(id)
    else
      mesh_terms = do_mesh_search(id)
    end
    @name=mesh_terms.collect(&:name).join(', ')
    params[:analysis]="mesh"
    show_core
  end 

  def show_org
    @name = get_org_name(params[:id])
    params[:analysis]="org"
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
    
  def build_graph(analysis, program, id, distance, stringency, include_orphans)
    # logger.warn "analysis=#{analysis}, program=#{program}, username=#{id}, distance=#{distance}, stringency=#{stringency}, include_orphans=#{include_orphans}"
    @graph_edges=[]
    #include_orphans = "0" if include_orphans.to_s != "1"
    graph = graph_new(program)
    
    graph = case analysis
          when "member"      :  build_member_graph( graph, program, id, distance, stringency, include_orphans)
          when "member_mesh" :  build_member_mesh_graph( graph, program, id, distance, stringency, include_orphans)
          when "mesh"        :  build_mesh_graph( graph, program, id, distance, stringency, include_orphans)
          when "org"         :  build_org_graph( graph, program, id, distance, stringency, include_orphans)
          when "org_mesh"    :  build_org_mesh_graph( graph, program, id, distance, stringency, include_orphans)
          else                  graph_no_data(graph, "Option #{analysis} was not found")
    end
    graph
  end
  
  def build_member_graph(graph, program, id, distance, stringency, include_orphans)
    @investigator = Investigator.find_by_username(id)
    if @investigator.nil?
      graph = graph_no_data(graph, "Investigator id #{id} was not found")
    else
      graph_newroot(graph, @investigator)
      co_authors = @investigator.co_authors.shared_pubs(stringency)
      graph = graph_add_nodes(program, graph, co_authors)
      if distance != "1"
        opts = {}
        opts[:fillcolor] = "#E0ECF8"
        co_authors.each do |co_author|
           graph = graph_add_nodes(program, graph, co_author.colleague.co_authors.shared_pubs(stringency), false, opts)
        end
      end
    end
    graph
  end

  def build_member_mesh_graph(graph, program, id, distance, stringency, include_orphans)
    @investigator = Investigator.find_by_username(id)
    if @investigator.nil?
      graph = graph_no_data(graph, "Investigator id #{id} was not found")
    else
      graph_newroot(graph, @investigator)
      similar_investigators = @investigator.all_similar_investigators.mesh_ic(stringency)
      graph = graph_add_nodes(program, graph, similar_investigators, true)
      if distance == "2"
        opts = {}
        opts[:fillcolor] = "#E0ECF8"
        similar_investigators.each do |similar|
          graph = graph_add_nodes(program, graph, similar.colleague.all_similar_investigators.mesh_ic(stringency), true, opts)
        end
      end
    end
    graph
  end

  def build_mesh_graph(graph, program, id, distance, stringency, include_orphans)
    if  id.to_i.to_s == id
      mesh_terms = Tag.find_all_by_id(id)
    else
      mesh_terms = do_mesh_search(id)
    end
    mesh_ids = mesh_terms.collect(&:id)
    colleagues=Investigator.for_tag_ids(mesh_ids)
    if colleagues.nil?
      graph = graph_no_data(graph, "No mesh_ids found: #{mesh_terms.collect(&:name)}")
     else
      colleagues.each do |colleague|
        co_authors = colleague.co_authors.shared_pubs(1)
        if  distance == "0"
          co_authors = co_authors.collect{|ic| colleagues.include?(ic.colleague) ? ic : nil }.compact
        end
        if include_orphans == "1" or co_authors.length > 0
          graph_secondaryroot(graph, colleague) 
          graph = graph_add_nodes(program, graph, co_authors) if co_authors.length > 0
          if distance == "2"
            opts = {}
            opts[:fillcolor] = "#E0ECF8"
            co_authors.each do |inner_colleague|
              inner_coauthors=inner_colleague.colleague.co_authors.shared_pubs(stringency)
              graph = graph_add_nodes(program, graph, inner_coauthors, false, opts)
            end
          end
        end
      end
    end
    graph
  end


 
  def build_org_graph(graph, program, id, distance, stringency,include_orphans)
    colleagues = get_colleagues(id)
    #slogger.info "colleagues: #{colleagues.length}"
    if colleagues.nil?
      graph = graph_no_data(graph, "No colleagues found in #{org.name}")
    else
      colleagues.each do |colleague|
        co_authors = colleague.co_authors.shared_pubs(stringency)
        if  distance == "0"
          co_authors = co_authors.collect{|ic| colleagues.include?(ic.colleague) ? ic : nil }.compact
        end
        if include_orphans == "1" or co_authors.length > 0
          graph_secondaryroot(graph, colleague) 
          graph = graph_add_nodes(program, graph, co_authors) if co_authors.length > 0
          if distance == "2"
            opts = {}
            opts[:fillcolor] = "#E0ECF8"
            co_authors.each do |inner_colleague|
              inner_coauthors=inner_colleague.colleague.co_authors.shared_pubs(stringency)
              graph = graph_add_nodes(program, graph, inner_coauthors, false, opts)
            end
          end
        end
      end
    end
    graph
  end
  
  def build_org_mesh_graph(graph, program, id, distance, stringency, include_orphans)
    colleagues = get_colleagues(id)
    # logger.info "colleagues: #{colleagues.length}"
    if colleagues.nil?
      graph = graph_no_data(graph, "No colleagues found in #{org.name}")
    else
      colleagues.each do |colleague|
        similar_investigators = colleague.all_similar_investigators.mesh_ic(stringency)
        if  distance == "0"
          similar_investigators = similar_investigators.collect{|ic| colleagues.include?(ic.colleague) ? ic : nil }.compact
        end
        if include_orphans == "1" or similar_investigators.length > 0
          graph_secondaryroot(graph, colleague)
          graph = graph_add_nodes(program, graph, similar_investigators, true) if similar_investigators.length > 0
          if distance == "2"
            opts = {}
            opts[:fillcolor] = "#E0ECF8"
            similar_investigators.each do |similar|
              inner_similar_investigators = similar.colleague.all_similar_investigators.mesh_ic(stringency)
              graph = graph_add_nodes(program, graph, inner_similar_investigators, true, opts)
            end
          end
        end
      end
    end
    graph
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