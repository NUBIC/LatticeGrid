require 'graph_generator'
require 'cytoscape_utilities'

require 'cytoscape_publications'
require 'cytoscape_studies'
require 'cytoscape_awards'


# now generate_cytoscape_data can create graphs with publications, studies and awards
def generate_cytoscape_data(investigator, max_depth, include_publications, include_awards, include_studies, depth=0, node_array=[], edge_array=[])
  node_array = handle_investigator_nodes(investigator, max_depth, include_publications, include_awards, include_studies, depth, node_array )
  
  edge_array = handle_investigator_edges(investigator, max_depth, include_publications, include_awards, include_studies, node_array, edge_array)
{
    :nodes => node_array,
    :edges => edge_array
}
end

def handle_investigator_nodes(investigator, max_depth, include_publications, include_awards, include_studies, depth, node_array)
  intermediate_node = ((include_awards+include_studies) > 0)
  node_array = generate_cytoscape_publication_nodes(investigator, max_depth, node_array,depth,intermediate_node) unless include_publications == 0
  node_array = generate_cytoscape_award_nodes(investigator, max_depth, node_array) unless include_awards == 0
  node_array = generate_cytoscape_study_nodes(investigator, max_depth, node_array) unless include_studies == 0
  return node_array
end

def handle_investigator_edges(investigator, max_depth, include_publications, include_awards, include_studies, node_array, edge_array)
  intermediate_node = ((include_awards+include_studies) > 0)
  edge_array = generate_cytoscape_publication_edges(investigator, max_depth, node_array, edge_array, intermediate_node) unless include_publications == 0
  edge_array = generate_cytoscape_award_edges(investigator, max_depth, node_array, edge_array) unless include_awards == 0
  edge_array = generate_cytoscape_study_edges(investigator, max_depth, node_array, edge_array) unless include_studies == 0
  return edge_array
end


def generate_cytoscape_org_data(org, max_depth, include_publications, include_awards, include_studies, depth=0, node_array=[])
  node_array = generate_cytoscape_org_nodes(org, max_depth, node_array, depth, include_publications, include_awards, include_studies)
  edge_array = generate_cytoscape_org_edges(org, max_depth, node_array, include_publications, include_awards, include_studies)
{
    :nodes => node_array,
    :edges => edge_array
}
end

def generate_cytoscape_org_nodes(org, max_depth, node_array, depth, include_publications, include_awards, include_studies)
  #         nodes: [ { id: "n1", label: "Node 1", score: 1.0 },
  #                  { id: "n2", label: "Node 2", score: 2.2 },
  #                  { id: "n3", label: "Node 3", score: 3.5 } ]
  return node_array if org.blank?
  max_weight=max_org_pubs(org)
  node_array << cytoscape_org_node_hash(org, max_weight, depth )
  depth +=1 unless include_awards > 0 or include_studies > 0
  # first iteration - just insert the direct nodes - max depth set to depth
  org.all_primary_or_member_faculty.each do |investigator|
    node_array = handle_investigator_nodes(investigator, max_depth, include_publications, include_awards, include_studies, depth, node_array)
  end
  node_array
end

def generate_cytoscape_org_edges(org, max_depth, node_array, include_publications, include_awards, include_studies, edge_array=[])
  org_index = org.name
  org.all_primary_or_member_faculty.each do |investigator|
    next if investigator.blank?
    investigator_index = investigator.id.to_s
    edge_array << cytoscape_edge_hash(edge_array.length, org_index, investigator_index, "", 1, "member of #{org_index}", "Org")
    edge_array = handle_investigator_edges(investigator, max_depth, include_publications, include_awards, include_studies, node_array, edge_array)
   end
  edge_array
end




