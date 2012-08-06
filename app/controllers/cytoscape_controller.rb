class CytoscapeController < ApplicationController
  before_filter :check_allowed, :only => [:awards, :studies, :show_all]

  caches_page( :show_org, :jit, :protovis, :member_cytoscape_data, :org_cytoscape_data, :member_protovis_data, :disallowed, :d3_data, :d3_date_data) if LatticeGridHelper.CachePages()
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

  #protovis methods
  def member_protovis_data
    investigator=Investigator.find_by_username(params[:id])
    depth = 1
    protovis_nodes = generate_protovis_nodes(investigator, depth)
    protovis_edges = generate_protovis_edges(investigator, protovis_nodes, depth)
    respond_to do |format|
      #format.json{ render :partial => "member_protovis_data", :locals => {:nodes_array_hash => protovis_nodes, :edges_array_hash => protovis_edges}  }
      format.json{ render :layout=> false, :json=> {:nodes => protovis_nodes.as_json(), :links => protovis_edges.as_json()}  }
    end
  end

  #d3 methods
  def chord
    @json_callback = "../cytoscape/d3_data.json"
    @title = 'Chord Diagram showing inter- and intra-programmatic publications for all programs'
    @stylesheets = [ 'publications', "latticegrid/#{lattice_grid_instance}"]
    unless params[:id].blank?
      program = OrganizationalUnit.find_by_id(params[:id])
      unless program.blank?
        flash[:notice] = "unable to find unit"
        params[:id] = nil
      else
        @json_callback = "../cytoscape/"+params[:id]+"/d3_data.json"
        @title = 'Chord Diagram showing inter- and intra-programmatic publications for '+program.name
      end
    end
    respond_to do |format|
      format.html { render :layout => 'd3'  }
      format.json{ render :layout=> false, :text => ""  }
    end
  end

#!!!!! 
  def investigator_chord 
    @title = 'Chord Diagram showing publications between various investigators'
    unless params[:id].blank? 
      master_investigator = Investigator.find_by_username(params[:id])
      @json_callback = "../cytoscape/"+params[:id]+"/d3_investigator_chord_data.json"
      if master_investigator.blank? 
        flash[:notice] = "unable to find investigator"
        params[:id] = nil 
      else 
        @title = 'Chord Diagram showing publications for ' + master_investigator.name
      end
    end
    respond_to do |format|
      format.html{ render :layout => 'd3'}
      format.json{ render :layout => false, :text => ""}
    end
  end

#!!!!!
  def investigator_edge_bundling 
    @title = 'Chord Diagram showing publications between various investigators'
    unless params[:id].blank? 
      master_investigator = Investigator.find_by_username(params[:id])
      @json_callback = "../cytoscape/" + params[:id] + "/d3_investigator_edge_data.json"
      if master_investigator.blank? 
        flash[:notice] = "unable to find investigator"
        params[:id] = nil 
      else 
        @title = 'Hierarchical Edge Bundling Diagram for investigator publications'
      end
    end
    respond_to do |format|
      format.html{ render :layout => 'd3bundle'}
      format.json{ render :layout => false, :text => ""}
    end
  end

#!!!!!
  def investigator_wordle
    @title = 'Wordle for NO ONE BECAUSE THE ID IS INVALID'
    unless params[:id].blank?
      master_investigator = Investigator.find_by_username(params[:id])
      if master_investigator.blank?
        flash[:notice] = "unable to find investigator"
        params[:id] = nil 
      else
        @title = 'Wordle synthesizing abstracts of ' + master_investigator.name
        @words = "../cytoscape/" + params[:id] + "/d3_investigator_wordle_data.json"
      end
    end
    respond_to do |format|
      format.html { render :layout => 'd3wordle'}
      format.json { render :layout => false, :text => ""}
    end
  end
  
  def chord_by_date
    start_date = params[:start_date] || 5.years.ago.to_date
    end_date = params[:end_date] || Date.today
    start_date = start_date.to_date
    end_date = end_date.to_date
    @json_callback = "../cytoscape/"+start_date.to_s(:db_date)+"/" + end_date.to_s(:db_date) + "/d3_date_data.json"
    @title = 'Chord Diagram showing inter- and intra-programmatic publications for all programs from ' + start_date.to_s(:justdate) + ' to ' + end_date.to_s(:justdate)
    respond_to do |format|
      format.html { render :layout => 'd3', :action => :chord  }
      format.json{ render :layout=> false, :text => ""  }
    end
  end

  def d3_data
    @units = @head_node.descendants.sort_by(&:abbreviation) 
    if (params[:id].blank?)
      # children are one level down - descendents are all levels down
      graph = d3_all_units_graph(@units)
    else 
      @master_unit = OrganizationalUnit.find_by_id(params[:id])
      graph = d3_master_unit_graph(@units,@master_unit)
    end
    depth = 1    
    respond_to do |format|
      #format.json{ render :partial => "member_protovis_data", :locals => {:nodes_array_hash => protovis_nodes, :edges_array_hash => protovis_edges}  }
      format.json{ render :layout=> false, :json => graph.as_json() }
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
        end
      end    

#!!! 
def d3_investigator_wordle_data
  if (params[:id])
    investigator = Investigator.find_all_by_username(params[:id]).first
    words = d3_wordle_data(investigator)
  end
words = words[50, 100] + words[words.length/2, words.length/2 + 150] + words[words.length - 100, 100]
    words.uniq!
  finalwords = []
  depth = 1
  respond_to do |format|
    format.json{ render :layout => false, :json => words.as_json()}
  end
end
    
  def d3_date_data
    @units = @head_node.descendants.sort_by(&:abbreviation)
    graph = d3_units_by_date_graph(@units, params[:start_date].to_date,  params[:end_date].to_date)
    depth = 1    
    respond_to do |format|
      #format.json{ render :partial => "member_protovis_data", :locals => {:nodes_array_hash => protovis_nodes, :edges_array_hash => protovis_edges}  }
      format.json{ render :layout=> false, :json => graph.as_json() }
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
   end
 
end
