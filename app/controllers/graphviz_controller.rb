class GraphvizController < ApplicationController

  caches_page(:show_member, :show_member_mesh, :show_org, :show_org_mesh, :investigator_wheel, :investigator_wheel_data, :org_wheel, :org_wheel_data) if LatticeGridHelper.cache_pages?

  require 'graphviz_config'
  require 'csv_generator'
  require 'graph_generator'

  helper :all

  include ApplicationHelper
  include GraphvizHelper
  include OrgsHelper
  include MeshHelper # for do_mesh_search

  def show_member
    @investigator = Investigator.find_by_username(params[:id])
    params[:analysis] = 'member'
    show_core
  end

  def show_member_awards
    @investigator = Investigator.find_by_username(params[:id])
    params[:analysis] = 'member_awards'
    show_core
  end

  def investigator_wheel
    @investigator = Investigator.find_by_username(params[:id])
    @page_title = "Wheel graph for #{@investigator.name}"
    @title = "Wheel graph showing the co-publications for #{@investigator.name}"
    @wheel_json_data = 'investigator_wheel_data.js'
    @wheel_action = 'investigator_wheel'
    render layout: 'wheel_graph', action: 'wheel_graph'
  end

  def investigator_wheel_data
    @investigator = Investigator.find_by_username(params[:id])
    the_array = []
    if @investigator
      co_authors = @investigator.co_authors
      the_array << wheel_graph_hash(@investigator, co_authors.map(&:colleague_id))
      co_authors.each do |co_author|
        the_array << wheel_graph_hash(co_author.colleague, co_authors.map(&:colleague_id) << @investigator.id) if co_author.colleague
      end
    end
    render json: the_array.as_json
  end

  def org_wheel
    @org = OrganizationalUnit.find(params[:id])
    @page_title = "Wheel graph for #{@org.name}"
    @title = "Wheel graph showing the interconnections between faculty in #{@org.name}"
    @wheel_json_data = 'org_wheel_data.js'
    @wheel_action = 'investigator_wheel'
    render :layout => 'wheel_graph', :action => 'wheel_graph'
  end

  def org_wheel_data
    @org = OrganizationalUnit.find(params[:id])
    the_array = []
    if @org
      @org.all_faculty.each do |pi|
        the_array << wheel_graph_hash(pi, faculty.collect(&:id))
      end
    end
    render :json => the_array.as_json
  end

  def show_member_mesh
    @investigator = Investigator.find_by_username(params[:id])
    params[:analysis] = "member_mesh"
    show_core
  end

  def show_mesh
    mesh_terms = MeshHelper.do_mesh_search(params[:id])
    @name = mesh_terms.collect(&:name).join(', ')
    params[:analysis] = "mesh"
    show_core
  end

  def show_org
    @name = get_org_name(params[:id])
    params[:analysis] = "org"
    show_core
   end

  def show_org_org
    @name = get_org_name(params[:id])
    params[:analysis] = "org_org"
    show_core
  end

  def show_org_mesh
    @name = get_org_name(params[:id])
    params[:analysis] = "org_mesh"
    show_core
  end

  # use get_graphviz to convert to a proper REST call. default remote_function call is very hard to make RESTful
  def get_graphviz
    handle_graphviz_setup
    @file_name = build_graphviz_restfulpath(params, @output_format)
    render :layout => false
  end

  # send_graphviz/:id/:analysis/:distance/:stringency/:program.:format'
  def send_graphviz_image
    handle_graphviz_setup
    @file_name = "public/#{@graph_path}#{params[:program]}.#{@output_format}"
    logger.warn "fgraphviz file name: #{@file_name}"
    send_file @file_name, :type => @content_type, :disposition => 'inline'
  end

  def wheel_graph_hash(user, allowed_connections)
    co_authors = user.co_authors
    connections = co_authors.collect do |pair|
      if allowed_connections.include?(pair.colleague_id) && !pair.colleague.nil?
        [pair.colleague.username, pair.publication_cnt]
      end
    end.compact
    {
      "connections" => connections,
      "text"=> user.name,
      "id" => user.username,
      "title" => "replace this text"
    }
  end
  private :wheel_graph_hash

  def handle_graphviz_setup
    # in 'graphviz_config'
    params[:program] ||= 'neato'
    params[:start_date] ||= (session[:last_load_date] - 5.years).to_date.to_s(:justdate)
    params[:end_date] ||= session[:last_load_date].to_s(:justdate)
    set_graphviz_defaults(params)
    # in the helper
    handle_graphviz_request
    handle_graph_file
  end
  private :handle_graphviz_setup

  def show_core
    params[:program] ||= 'neato'
    params[:start_date] ||= (session[:last_load_date] - 5.years).to_date.to_s(:justdate)
    params[:end_date] ||= session[:last_load_date].to_s(:justdate)
    set_graphviz_defaults(params)

    params[:format] =  nil
    if !params[:id].blank?
      respond_to do |format|
        format.html { render }
      end
    else
      redirect_to show_org_graph_url(1)
    end
  end
  private :show_core

  def get_org_name(id)
    ids=id.split(",")
    if ids.length > 1
      OrganizationalUnit.where("id in (:ids)", { :ids=>ids }).all.collect(&:name).join(", ")
    else
      OrganizationalUnit.find(id).name
    end
  end
  private :get_org_name

  def get_colleagues(id)
    ids = id.split(",")
    if ids.length > 1
      orgs = OrganizationalUnit.where("id in (:ids)", { :ids=>ids }).all
      colleagues = orgs.collect{|org| org.all_faculty }.flatten.uniq
    else
      org = OrganizationalUnit.find(id)
      colleagues = org.all_faculty
    end
  end
  private :get_colleagues
end
