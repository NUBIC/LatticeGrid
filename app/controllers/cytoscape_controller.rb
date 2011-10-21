class CytoscapeController < ApplicationController
  before_filter :check_allowed, :only => [:awards, :studies]

  caches_page( :show, :jit, :protovis, :member_cytoscape_data, :member_protovis_data, :disallowed, :d3_data) if LatticeGridHelper.CachePages()
  caches_action( :listing, :investigator, :show, :awards, :studies )  if LatticeGridHelper.CachePages()
  
  require 'cytoscape_config'
  require 'cytoscape_generator'
  require 'protovis_generator'
  require 'd3_generator'
  require 'infoviz_generator'
  include ApplicationHelper
  include CytoscapeHelper
  include InvestigatorsHelper


  def index
  end

  # cytoscape show
  def show
    params[:depth] ||= 1
    params[:include_awards] ||= 0
    params[:include_studies] ||= 0
    @title = "Publications Collaborations"
    @investigator=Investigator.find_by_username(params[:id])
  end

  def awards
    params[:depth] ||= 1
    params[:include_awards] ||= 1
    params[:include_studies] ||= 0
    @title = "Award Collaborations"
    @investigator=Investigator.find_by_username(params[:id])
    render :action => :show
  end

  def studies
    params[:depth] ||= 1
    params[:include_awards] ||= 0
    params[:include_studies] ||= 1
    @title = "Research Study Collaborations"
    @investigator=Investigator.find_by_username(params[:id])
    render :action => :show
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
    investigator=Investigator.find_by_username(params[:id])
    params[:depth] ||= 1
    depth = params[:depth].to_i
    params[:include_awards] ||= 1
    params[:include_studies] ||= 0
    include_awards = params[:include_awards].to_i
    include_studies = params[:include_studies].to_i
    data_schema = generate_cytoscape_schema()
    if !include_studies.blank? and include_studies != 0
      data = generate_cytoscape_study_data(investigator, depth)
    elsif !include_awards.blank? and include_awards != 0
      data = generate_cytoscape_award_data(investigator, depth)
    else
      data = generate_cytoscape_data(investigator, depth)
    end
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
    respond_to do |format|
      format.html { render :layout => 'd3'  }
      format.json{ render :layout=> false, :text => ""  }
    end
    
  end

  def d3_data
    if (params[:id].blank?)
      # children are one level down - descendents are all levels down
      @units = @head_node.descendants.sort_by(&:abbreviation)
    else 
      @units = OrganizationalUnit.find_all_by_id(params[:id])
    end
    graph = d3_units_graph(@units)
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

 
end
