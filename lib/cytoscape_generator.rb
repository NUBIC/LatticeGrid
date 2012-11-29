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

def generate_cytoscape_org_org_data(orgs, max_depth, include_publications, include_awards, include_studies, depth=0, node_array=[], edge_array=[])
  all_orgs = Department.all - orgs
  orgs.each do |org|
    org_index = generate_org_node_id(org)
    node_array << cytoscape_org_node_hash(org, org.abstracts_count, 0 )
    all_orgs.each do |intersecting_org|
      shared_abstracts_count = org.abstract_ids_shared_with_org_obj(intersecting_org).count
      intersecting_org_index = generate_org_node_id(intersecting_org)
      if shared_abstracts_count >= 10
        edge_index = "#{org_index}_#{intersecting_org_index}"
        node_array << cytoscape_org_node_hash(intersecting_org, intersecting_org.abstracts_count, 1 ) unless cytoscape_array_has_key?(node_array, intersecting_org_index)
        edge_array << cytoscape_edge_hash(edge_index, org_index, intersecting_org_index, shared_abstracts_count.to_s, shared_abstracts_count, "#{shared_abstracts_count} shared publications between #{org.name} and #{intersecting_org.name}", "Org") unless cytoscape_array_has_key?(edge_array, edge_index)
      end
    end
  end
{
    :nodes => node_array,
    :edges => edge_array
}
end


def generate_cytoscape_all_org_data(include_publications, include_awards, include_studies, start_date, end_date, node_array=[], edge_array=[])
  head_node = OrganizationalUnit.head_node(LatticeGridHelper.menu_head_abbreviation())
  all_orgs = head_node.leaves
  (0...all_orgs.length).each do |i|
    org = all_orgs[i]
    next if org.abstracts_count < 100 or LatticeGridHelper.test_org_type(org) 
    org_index = generate_org_node_id(org)
    node_array << cytoscape_org_node_hash(org, org.abstracts_count, 1 )
    (i+1...all_orgs.length).each do |j|
      intersecting_org = all_orgs[j]
      next if intersecting_org.abstracts_count < 100 or LatticeGridHelper.test_org_type(intersecting_org) 
      shared_abstracts_count = org.abstract_ids_shared_with_org_obj(intersecting_org).count
      intersecting_org_index = generate_org_node_id(intersecting_org)
      if shared_abstracts_count >= 10
        edge_index = "#{org_index}_#{intersecting_org_index}"
        edge_array << cytoscape_edge_hash(edge_index, org_index, intersecting_org_index, shared_abstracts_count.to_s, shared_abstracts_count, "#{shared_abstracts_count} shared publications between #{org.name} and #{intersecting_org.name}", "Org") unless cytoscape_array_has_key?(edge_array, edge_index)
      end
    end
  end
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
  org_index = generate_org_node_id(org)
  org.all_primary_or_member_faculty.each do |investigator|
    next if investigator.blank?
    investigator_index = investigator.id.to_s
    edge_array << cytoscape_edge_hash(edge_array.length, org_index, investigator_index, "", 1, "member of #{org.name}", "Org")
    edge_array = handle_investigator_edges(investigator, max_depth, include_publications, include_awards, include_studies, node_array, edge_array)
   end
  edge_array
end




