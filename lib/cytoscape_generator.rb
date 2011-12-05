require 'graph_generator'
require 'cytoscape_utilities'

require 'cytoscape_publications'
require 'cytoscape_studies'
require 'cytoscape_awards'


# now generate_cytoscape_data can create graphs with publications, studies and awards
def generate_cytoscape_data(investigator, max_depth, include_publications=1, include_awards=1, include_studies=1)
  node_array = []
  intermediate_node = ((include_awards+include_studies) > 0)
  
  node_array = generate_cytoscape_publication_nodes(investigator, max_depth, node_array,0,intermediate_node) unless include_publications.blank? or include_publications == 0
  node_array = generate_cytoscape_award_nodes(investigator, max_depth, node_array) unless include_awards.blank? or include_awards == 0
  node_array = generate_cytoscape_study_nodes(investigator, max_depth, node_array) unless include_studies.blank? or include_studies == 0
  edge_array = []
  edge_array = generate_cytoscape_publication_edges(investigator, max_depth, node_array, edge_array, intermediate_node) unless include_publications.blank? or include_publications == 0
  edge_array = generate_cytoscape_award_edges(investigator, max_depth, node_array, edge_array) unless include_awards.blank? or include_awards == 0
  edge_array = generate_cytoscape_study_edges(investigator, max_depth, node_array, edge_array) unless include_studies.blank? or include_studies == 0
{
    :nodes => node_array,
    :edges => edge_array
}
end

def generate_cytoscape_org_data(org, max_depth)
  node_array = generate_cytoscape_org_nodes(org, max_depth)
{
    :nodes => node_array,
    :edges => generate_cytoscape_org_edges(org, max_depth, node_array)
}
end

def generate_cytoscape_org_nodes(org, max_depth, node_array=[], depth=0)
  #         nodes: [ { id: "n1", label: "Node 1", score: 1.0 },
  #                  { id: "n2", label: "Node 2", score: 2.2 },
  #                  { id: "n3", label: "Node 3", score: 3.5 } ]
  return node_array if org.blank?
  max_weight=max_org_pubs(org)
  node_array << cytoscape_org_node_hash(org, max_weight, depth )
  depth +=1
  # first iteration - just insert the direct nodes - max depth set to depth
  org.all_primary_or_member_faculty.each do |investigator|
    node_array = generate_cytoscape_publication_nodes(investigator, depth, node_array, depth ) unless cytoscape_array_has_key?(node_array, investigator.id)
  end
  if max_depth > depth
    # second iteration - go deeper
    org.all_primary_or_member_faculty.each do |investigator|
      node_array = generate_cytoscape_publication_nodes(investigator, max_depth, node_array, depth ) 
    end
  end
  node_array
end

