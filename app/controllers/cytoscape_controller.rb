class CytoscapeController < ApplicationController
  before_filter :check_allowed, :only => [:awards]

  caches_page( :show, :jit, :protovis, :member_cytoscape_data, :member_protovis_data, :disallowed) if LatticeGridHelper.CachePages()
  
  require 'cytoscape_config'
  require 'cytoscape_generator'
  require 'protovis_generator'
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
    @investigator=Investigator.find_by_username(params[:id])
  end

  def awards
    params[:depth] ||= 1
    params[:include_awards] ||= 1
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
    include_awards = params[:include_awards].to_i
    data_schema = generate_cytoscape_schema()
    if !include_awards.blank? and include_awards != 0
      data = generate_cytoscape_award_data(investigator, depth)
    else
      data = generate_cytoscape_data(investigator, depth)
    end
    respond_to do |format|
      #format.json{ render :partial => "member_protovis_data", :locals => {:nodes_array_hash => nodes_array_hash, :edges_array_hash => edges_array_hash}  }
      format.json{ render :layout=> false, :json=> {:dataSchema => data_schema.as_json(), :data => data.as_json()}  }
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


   private  
   def check_allowed
     unless allowed_ip(get_client_ip()) then 
       redirect_to disallowed_awards_url
     end
   end

 
end
