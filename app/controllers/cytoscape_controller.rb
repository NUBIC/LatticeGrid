class CytoscapeController < ApplicationController
  before_filter :check_allowed, :only => [:awards, :studies, :show_all]

  caches_page( :show_org, :jit, :protovis, :member_cytoscape_data, :org_cytoscape_data, :org_org_cytoscape_data, :member_protovis_data, :disallowed, :d3_data, :d3_date_data, :investigator_edge_bundling, :d3_investigator_edge_data, :investigator_wordle, :d3_investigator_wordle_data, :simularity_wordle, :d3_investigators_wordle_data, :d3_investigator_chord_data, :show_all_orgs, :all_org_cytoscape_data, :d3_program_investigators_chord_data, :d3_all_investigators_chord_data) if LatticeGridHelper.CachePages()
  caches_action( :listing, :investigator, :awards, :studies )  if LatticeGridHelper.CachePages()

  require 'cytoscape_config'
  require 'cytoscape_generator'
  require 'protovis_generator'
  require 'd3_generator'
  require 'infoviz_generator'
  include ApplicationHelper
  include CytoscapeHelper
  include InvestigatorsHelper
  include OrgsHelper


  def index
  end

  # cytoscape show
  def show
    params[:include_awards] ||= "0"
    params[:include_studies] ||= "0"
    handle_data_params
    @title ||= "Publications Collaborations"
    @investigator=Investigator.find_by_username(params[:id])
    @dataurl ||= member_cytoscape_data_url(params[:id], params[:depth], params[:include_publications], params[:include_awards], params[:include_studies])
    @base_path_without_depth = base_path(true)
    render :action => :show
  end

  def showjs
    params[:include_awards] ||= "0"
    params[:include_studies] ||= "0"
    handle_data_params
    @title ||= "Publications Collaborations"
    @investigator=Investigator.find_by_username(params[:id])
    @dataurl ||= member_cytoscape_data_url(params[:id], params[:depth], params[:include_publications], params[:include_awards], params[:include_studies])
    @base_path_without_depth = base_path(true)
    render :action => :show, :layout => 'cytoscapejs'
  end

  def show_all
    handle_data_params
    @title = "Publication/Award/Study Collaborations"
    show
  end

  def show_org
    params[:include_awards] ||= "0"
    params[:include_studies] ||= "0"
    handle_data_params
    @title = "Publications Collaborations"
    @org = find_unit_by_id_or_name(params[:id])
    @dataurl = org_cytoscape_data_url(params[:id], params[:depth], params[:include_publications], params[:include_awards], params[:include_studies])

    show
  end

  def show_org_org
    params[:include_awards] ||= "0"
    params[:include_studies] ||= "0"
    handle_data_params
    @org = find_unit_by_id_or_name(params[:id])
    @title = "#{@org.name}: inter-unit ollaborations"
    @dataurl = org_org_cytoscape_data_url(params[:id], params[:depth], params[:include_publications], params[:include_awards], params[:include_studies])

    show
  end

  def show_all_orgs
    params[:include_awards] ||= "1"
    params[:include_studies] ||= "0"
    params[:start_date] ||= ('2008-01-01'.to_date).to_s
    params[:end_date] ||= ('2012-12-31'.to_date).to_s
    handle_data_params
    @title = "All inter-unit collaborations from #{params[:start_date]} to #{params[:end_date]}"
    @dataurl = all_org_cytoscape_data_url(params[:include_publications], params[:include_awards], params[:include_studies], params[:start_date], params[:end_date] )

    show
  end

  def show_all_orgs_old
    params[:include_awards] ||= "1"
    params[:include_studies] ||= "0"
    params[:start_date] ||= ('2008-01-01'.to_date - 5.years).to_s
    params[:end_date] ||= ('2012-12-31'.to_date - 5.years).to_s
    handle_data_params
    @title = "All inter-unit collaborations from #{params[:start_date]} to #{params[:end_date]}"
    @dataurl = all_org_cytoscape_data_url(params[:include_publications], params[:include_awards], params[:include_studies], params[:start_date], params[:end_date] )

    show
  end


  def awards
    params[:include_publications] ||= "0"
    params[:include_studies] ||= "0"
    handle_data_params
    @title = "Award Collaborations"
    @investigator=Investigator.find_by_username(params[:id])
    show
  end

  def awards_org
    params[:include_publications] ||= "0"
    params[:include_studies] ||= "0"
    params[:include_awards] ||= "1"
    handle_data_params
    @title = "Award Collaborations"
    @org = find_unit_by_id_or_name(params[:id])
    @dataurl = org_cytoscape_data_url(params[:id], params[:depth], params[:include_publications], params[:include_awards], params[:include_studies])
    show
  end

  def studies
    params[:include_awards] ||= "0"
    params[:include_publications] ||= "0"
    handle_data_params
    @title = "Research Study Collaborations"
    @investigator=Investigator.find_by_username(params[:id])
    show
  end

  def studies_org
    params[:include_awards] ||= "0"
    params[:include_publications] ||= "0"
    handle_data_params
    @title = "Research Study Collaborations"
    @org = find_unit_by_id_or_name(params[:id])
    @dataurl = org_cytoscape_data_url(params[:id], params[:depth], params[:include_publications], params[:include_awards], params[:include_studies])
    show
  end

  def org_all
    handle_data_params
    @title = "Publication/Award/Study Collaborations"
    @org = find_unit_by_id_or_name(params[:id])
    @dataurl = org_cytoscape_data_url(params[:id], params[:depth], params[:include_publications], params[:include_awards], params[:include_studies])
    show
  end

  def jit
  	@javascripts = [ 'jit', 'example2', 'FusionCharts', 'ddsmoothmenu', 'jquery.min' ]
  	@stylesheets = [ 'publications', "latticegrid/#{lattice_grid_instance}", 'base', 'ForceDirected'  ]
    investigator=Investigator.find_by_username(params[:id])
    @subtree_hash = adjacencies(investigator)
  end

  def protovis
    #needs the username
    render :layout => false
  end

  def member_cytoscapejs_data
    @investigator=Investigator.find_by_username(params[:id])
    handle_data_params
    data = generate_cytoscapejs_data(@investigator, params[:depth].to_i, params[:include_publications].to_i, params[:include_awards].to_i, params[:include_studies].to_i)
    respond_to do |format|
       format.js{ render :layout=> false, :json=> {:data => data.as_json()}  }
    end
  end


  def member_cytoscape_data
    @investigator=Investigator.find_by_username(params[:id])
    handle_data_params
    data_schema = generate_cytoscape_schema()
    data = generate_cytoscape_data(@investigator, params[:depth].to_i, params[:include_publications].to_i, params[:include_awards].to_i, params[:include_studies].to_i)
    respond_to do |format|
      format.json{ render :layout=> false, :json=> {:dataSchema => data_schema.as_json(), :data => data.as_json()}  }
      format.js{ render :layout=> false, :json=> {:dataSchema => data_schema.as_json(), :data => data.as_json()}  }
    end
  end

  def org_cytoscape_data
    @org = find_unit_by_id_or_name(params[:id])
    handle_data_params
    data_schema = generate_cytoscape_schema()
    data = generate_cytoscape_org_data(@org, params[:depth].to_i, params[:include_publications].to_i, params[:include_awards].to_i, params[:include_studies].to_i)
    respond_to do |format|
      format.json{ render :layout=> false, :json=> {:dataSchema => data_schema.as_json(), :data => data.as_json()}  }
      format.js{ render :layout=> false, :json=> {:dataSchema => data_schema.as_json(), :data => data.as_json()}  }
    end
  end

  def org_org_cytoscape_data
    orgs = get_orgs(params[:id])
    handle_data_params
    data_schema = generate_cytoscape_schema()
    data = generate_cytoscape_org_org_data(orgs, params[:depth].to_i, params[:include_publications].to_i, params[:include_awards].to_i, params[:include_studies].to_i)
    respond_to do |format|
      format.json{ render :layout=> false, :json=> {:dataSchema => data_schema.as_json(), :data => data.as_json()}  }
      format.js{ render :layout=> false, :json=> {:dataSchema => data_schema.as_json(), :data => data.as_json()}  }
    end
  end

  def all_org_cytoscape_data
    handle_data_params
    data_schema = generate_cytoscape_schema()
    data = generate_cytoscape_all_org_data(params[:include_publications].to_i, params[:include_awards].to_i, params[:include_studies].to_i, params[:start_date], params[:end_date])
    respond_to do |format|
      format.json{ render :layout=> false, :json=> {:dataSchema => data_schema.as_json(), :data => data.as_json()}  }
      format.js{ render :layout=> false, :json=> {:dataSchema => data_schema.as_json(), :data => data.as_json()}  }
    end
  end

  def export
    #all the data should be passed in as a big blob
    send_data(request.raw_post, :filename => "cytoscape.pdf", :type => "application/pdf")
  end



  #protovis methods
  def member_protovis_data
    investigator=Investigator.find_by_username(params[:id])
    depth = 1
    protovis_nodes = generate_protovis_nodes(investigator, depth)
    protovis_edges = generate_protovis_edges(investigator, protovis_nodes, depth)
    respond_to do |format|
      #format.json{ render :partial => "member_protovis_data", :locals => {:nodes_array_hash => protovis_nodes, :edges_array_hash => protovis_edges}  }
      format.json{ render :layout=> false, :json=> {:nodes => protovis_nodes.as_json(), :links => protovis_edges.as_json()}  }
      format.js{ render :layout=> false, :json=> {:nodes => protovis_nodes.as_json(), :links => protovis_edges.as_json()}  }
    end
  end

  #d3 methods
  # this one is a collection - doesn't have an :id parameter

  def chord
    @json_callback = "../cytoscape/d3_data.js"
    @title = 'Chord Diagram showing inter- and intra-programmatic connections through multi-investigator publications'
    respond_to do |format|
      format.html { render :layout => 'd3'  }
      format.json{ render :layout=> false, :text => ""  }
    end
  end

  #d3 methods
  def program_chord
    @json_callback = "../cytoscape/d3_data.js"
    @title = 'Chord Diagram showing programmatic connections'
    unless params[:id].blank?
      program = OrganizationalUnit.find(params[:id])
      if program.blank?
        flash[:notice] = "unable to find unit #{params[:id]}"
        params[:id] = nil
      else
        @json_callback = "../cytoscape/"+params[:id]+"/d3_program_investigators_chord_data.js"
        @title = 'Chord Diagram showing inter- and intra-programmatic publications for '+program.name
      end
    end
    respond_to do |format|
      format.html { render 'chord', :layout => 'd3'  }
      format.json{ render :layout=> false, :text => ""  }
    end
  end

#!!!!!
  def investigator_chord
    @title = 'Chord Diagram showing publications between various investigators'
    unless params[:id].blank?
      @investigator = Investigator.find_by_username(params[:id])
      @json_callback = "../cytoscape/"+params[:id]+"/d3_investigator_chord_data.js"
      if @investigator.blank?
        flash[:notice] = "unable to find investigator"
        params[:id] = nil
      else
        @title = 'Chord Diagram showing investigator collaborations through publications for ' + @investigator.name
      end
    end
    respond_to do |format|
      format.html{ render :layout => 'd3'}
      format.json{ render :layout => false, :text => ""}
    end
  end

#!!!!!
  def all_investigator_chord
    @title = 'Chord Diagram showing publications between investigators'
    @json_callback = "../cytoscape/d3_all_investigators_chord_data.js"
    respond_to do |format|
      format.html{ render 'chord', :layout => 'd3'}
      format.json{ render :layout => false, :text => ""}
    end
  end


#!!!!!
  def investigator_edge_bundling
    @title = 'Hierarchical Edge Bundle Diagram by program and investigator'
    @json_callback = "../cytoscape_d3_investigator_edge_data.js"
    respond_to do |format|
      format.html{ render :layout => 'd3'}
      format.json{ render :layout => false, :text => ""}
    end
  end

#!!!!!
  def investigator_wordle
    @title = 'Wordle for NO ONE BECAUSE THE ID IS INVALID'
    unless params[:id].blank?
      @investigator = Investigator.find_by_username(params[:id])
      if @investigator.blank?
        flash[:notice] = "unable to find investigator"
        params[:id] = nil
      else
        @title = 'Word cloud (Wordle) display of abstracts from ' + @investigator.name
        @json_callback = "../cytoscape/" + params[:id] + "/d3_investigator_wordle_data.js"
      end
    end
    respond_to do |format|
      format.html { render :layout => 'd3'}
      format.json { render :layout => false, :text => ""}
    end
  end

  def simularity_wordle
    @title = 'Wordle for NO ONE BECAUSE THE ID IS INVALID'
    unless params[:id].blank?
      @investigators = Investigator.all(:conditions=>["investigators.username in (:usernames)",{:usernames=>params[:id].split(",")}])
      if @investigators.blank?
        flash[:notice] = "unable to find investigator"
        params[:id] = nil
      else
        @title = 'Word cloud (Wordle) similarity between ' + @investigators.map(&:name).join(" and ")
        @json_callback = "../cytoscape/" + params[:id] + "/d3_investigator_similarity_wordle_data.js"
      end
    end
    respond_to do |format|
      format.html { render :layout => 'd3', :action => :investigator_wordle }
      format.json { render :layout => false, :text => ""}
    end
  end

  def difference_wordle
    @title = 'Wordle for NO ONE BECAUSE THE ID IS INVALID'
    unless params[:id].blank?
      investigator1 = Investigator.find_by_username(params[:id].split(",")[0])
      investigator2 = Investigator.find_by_username(params[:id].split(",")[1])
      @investigators=[investigator1,investigator2]
      if @investigators.blank?
        flash[:notice] = "unable to find investigator"
        params[:id] = nil
      else
        @title = 'Word cloud (Wordle) difference between ' + @investigators.map(&:name).join(" and ")
        @json_callback1 = "../cytoscape/" + params[:id] + "/d3_investigator_difference_wordle_data.js"
        @json_callback2 = "../cytoscape/" + params[:id].split(",")[1] + "," + params[:id].split(",")[0] + "/d3_investigator_difference_wordle_data.js"
      end
    end
    respond_to do |format|
      format.html { render :layout => 'd3', :action => :investigator_difference_wordle }
      format.json { render :layout => false, :text => ""}
    end
  end

  def chord_by_date
    start_date = params[:start_date] || 5.years.ago.to_date
    end_date = params[:end_date] || Date.today
    start_date = start_date.to_date
    end_date = end_date.to_date
    @json_callback = "../cytoscape/"+start_date.to_s(:db_date)+"/" + end_date.to_s(:db_date) + "/d3_date_data.js"
    @title = 'Chord Diagram showing inter- and intra-programmatic publications for all programs from ' + start_date.to_s(:justdate) + ' to ' + end_date.to_s(:justdate)
    respond_to do |format|
      format.html { render :layout => 'd3', :action => :chord  }
      format.json{ render :layout=> false, :text => ""  }
    end
  end

  def d3_data
    @units = @head_node.descendants.sort_by(&:abbreviation)
    if (params[:id].blank?)
      # children are one level down - descendants are all levels down
      graph = d3_all_units_graph(@units)
    else
      @master_unit = OrganizationalUnit.find(params[:id])
      graph = d3_master_unit_graph(@units,@master_unit)
    end
    depth = 1
    respond_to do |format|
      #format.json{ render :partial => "member_protovis_data", :locals => {:nodes_array_hash => protovis_nodes, :edges_array_hash => protovis_edges}  }
      format.json{ render :layout=> false, :json => graph.as_json() }
      format.js{ render :layout=> false, :json => graph.as_json() }
    end
  end

#!!!!
  def d3_program_investigators_chord_data
    #@investigators = @head_node.descendants.sort_by(&:name)
    if (params[:id])
      program = OrganizationalUnit.find(params[:id])
      graph = d3_all_investigators_graph(program)
    end
    depth = 1
    respond_to do |format|
      format.json{ render :layout => false, :json => graph.as_json()}
      format.js{ render :layout => false, :json => graph.as_json()}
    end
  end


#!!!!
  def d3_all_investigators_chord_data
    #@investigators = @head_node.descendants.sort_by(&:name)
    graph = d3_all_investigators_graph()
    depth = 1
    respond_to do |format|
      format.json{ render :layout => false, :json => graph.as_json()}
      format.js{ render :layout => false, :json => graph.as_json()}
    end
  end


#!!!!
  def d3_investigator_chord_data
      #@investigators = @head_node.descendants.sort_by(&:name)
      if (params[:id])
        investigator = Investigator.find_all_by_username(params[:id]).first
        graph = d3_master_investigator_graph(investigator)
      end
      depth = 1
      respond_to do |format|
        format.json{ render :layout => false, :json => graph.as_json()}
        format.js{ render :layout => false, :json => graph.as_json()}
      end
    end

  #!!!!!
  def d3_investigator_edge_data
    #@investigators = @head_node.descendants.sort_by(&:name)
    departments = OrganizationalUnit.all
    #investigators = []
    #departments.each {|dep|
    #  dep.primary_or_member_faculty.each {|inv|
    #      investigators << inv
    #    }
    #  }
    investigators = Investigator.all
    investigators.sort!{|a, b| a.unit_list().first <=> b.unit_list().first}

    graph = d3_all_investigators_bundle(investigators.uniq)
    depth = 1
    respond_to do |format|
      format.json{ render :layout => false, :json => graph.as_json()}
      format.js{ render :layout => false, :json => graph.as_json()}
    end
  end

  #!!!
  def d3_investigator_wordle_data
    words = []
    if (params[:id])
      investigator = Investigator.find_by_username(params[:id])
      words = WordFrequency.investigator_wordle_data(investigator)
      words = WordFrequency.wordle_distribution(words)
    end
    depth = 1
    respond_to do |format|
      format.json{ render :layout => false, :json => words.as_json()}
      format.js{ render :layout => false, :json => words.as_json()}
    end
  end

  def d3_investigator_similarity_wordle_data
    words = []
    if (params[:id])
      investigators = Investigator.all(:conditions=>["investigators.username in (:usernames)",{:usernames=>params[:id].split(",")}])
      words = WordFrequency.investigators_wordle_data(investigators)
      words = WordFrequency.wordle_distribution(words, 200)
    end
    respond_to do |format|
      format.json{ render :layout => false, :json => words.as_json()}
      format.js{ render :layout => false, :json => words.as_json()}
    end
  end

  def d3_investigator_difference_wordle_data
    words = []
    if (params[:id])
      investigator1 = Investigator.find_by_username(params[:id].split(",")[0])
      investigator2 = Investigator.find_by_username(params[:id].split(",")[1])
      words = WordFrequency.investigators_difference_wordle_data([investigator1, investigator2])
      words = WordFrequency.wordle_distribution(words, 125)
    end
    respond_to do |format|
      format.json{ render :layout => false, :json => words.as_json()}
      format.js{ render :layout => false, :json => words.as_json()}
    end
  end

  def d3_date_data
    @units = @head_node.descendants.sort_by(&:abbreviation)
    graph = d3_units_by_date_graph(@units, params[:start_date].to_date,  params[:end_date].to_date)
    depth = 1
    respond_to do |format|
      #format.json{ render :partial => "member_protovis_data", :locals => {:nodes_array_hash => protovis_nodes, :edges_array_hash => protovis_edges}  }
      format.json{ render :layout=> false, :json => graph.as_json() }
      format.js{ render :layout=> false, :json => graph.as_json() }
    end
  end

  private

  def check_allowed
    unless allowed_ip(get_client_ip()) then
      redirect_to disallowed_awards_url
    end
  end

  def handle_data_params
    params[:depth] ||= "1"
    params[:include_awards] ||= "1"
    params[:include_studies] ||= "1"
    params[:include_publications] ||= "1"
    params[:include_publications] = "1" if params[:include_awards] == "0" and params[:include_studies] == "0"
    params[:start_date] ||= 5.years.ago.to_date.to_s
    params[:start_date] ||= 10.years.ago.to_date.to_s
    params[:end_date] ||= Date.today.to_s
    params[:end_date] ||= 5.years.ago.to_date.to_s
  end

end
