require 'cytoscape_utilities'

#add_intermediate_nodes makes the graph match up with the award and study graphs
def generate_cytoscape_publication_nodes(investigator, max_depth, node_array=[], depth=0, add_intermediate_nodes=false)
  #         nodes: [ { id: "n1", label: "Node 1", score: 1.0 },
  #                  { id: "n2", label: "Node 2", score: 2.2 },
  #                  { id: "n3", label: "Node 3", score: 3.5 } ]
  return node_array if investigator.blank?
  if depth == 0
    # this is for the case where the investigator is in the middle. Make them the biggest node
    max_weight=max_colleague_pubs(investigator)+10
  else
    max_weight = investigator.total_publications
  end
  node_array << cytoscape_investigator_node_hash(investigator, max_weight, depth ) unless cytoscape_array_has_key?(node_array, investigator.id)
  depth +=1
  return node_array if depth > max_depth
  investigator.co_authors.each { |connection| 
    next if connection.colleague.blank?
    node_array << cytoscape_investigator_node_hash(connection.colleague, connection.colleague.total_publications, depth) unless cytoscape_array_has_key?(node_array, connection.colleague_id)
    if add_intermediate_nodes
      node_array << cytoscape_publication_node_hash(connection, connection.publication_cnt, depth) unless cytoscape_array_has_key?(node_array, "IC_#{connection.id}")
    end
  }
  if max_depth > depth
    investigator.co_authors.each { |connection| 
      node_array = generate_cytoscape_publication_nodes(connection.colleague, max_depth, node_array, depth, add_intermediate_nodes)
    }
  end
  node_array
end

def max_colleague_pubs(investigator)
  return 0 if investigator.blank?
  max_pubs = investigator.total_publications
  investigator.co_authors.each { |connection| 
    max_pubs = connection.colleague.total_publications if connection.colleague.total_publications > max_pubs
  }
  max_pubs
end

def max_org_pubs(org)
  return 0 if org.blank? || org.all_primary_or_member_faculty.blank?
  org.all_primary_or_member_faculty.map(&:total_publications).max
end

def cytoscape_org_node_hash(org, weight=10, depth=1)
 {
   :id => org.name,
   :element_type => "Org",
   :label => org.name,
   :weight => weight,
   :depth => depth,
   :tooltiptext => org.abbreviation || org.name
 }
end

def cytoscape_publication_node_hash(investigator_colleague, weight=10, depth=1)
 {
   :id => "IC_#{investigator_colleague.id}",
   :element_type => "Publication",
   :label => "Pubs",
   :weight => weight,
   :depth => depth,
   :tooltiptext => investigator_colleague_edge_tooltip(investigator_colleague,investigator_colleague.investigator, investigator_colleague.colleague)
 }
end

def generate_cytoscape_publication_edges(investigator, depth, node_array, edge_array=[], add_intermediate_nodes=false)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  return edge_array if investigator.blank?
  investigator_index = investigator.id.to_s
  investigator.co_authors.each { |connection| 
    next if connection.colleague.blank?
    colleague_index = connection.colleague_id.to_s
    publication_index = "IC_#{connection.id}"
    next unless cytoscape_array_has_key?(node_array, colleague_index) 
    next if add_intermediate_nodes and not cytoscape_array_has_key?(node_array, publication_index)
    tooltiptext=investigator_colleague_edge_tooltip(connection,investigator,connection.colleague)
    if add_intermediate_nodes
      unless cytoscape_edge_array_has_key?(edge_array, investigator_index, publication_index)
        edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, publication_index, connection.publication_cnt.to_s, connection.publication_cnt, tooltiptext, "Publication")
        edge_array << cytoscape_edge_hash(edge_array.length, publication_index, colleague_index, connection.publication_cnt.to_s, connection.publication_cnt, tooltiptext, "Publication")
      end
    else
      unless cytoscape_edge_array_has_key?(edge_array, investigator_index, colleague_index)
        edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, colleague_index, connection.publication_cnt.to_s, connection.publication_cnt, tooltiptext, "Publication")
      end
    end
    if (depth > 1)
      edge_array = generate_cytoscape_publication_edges(connection.colleague, (depth-1), node_array, edge_array, add_intermediate_nodes)
    end
  }
  edge_array
end

 def investigator_colleague_edge_tooltip(connection, root, leaf)
   return "root doesn't exist" if root.blank?
   return "leaf doesn't exist" if leaf.blank?
   "#{connection.publication_cnt} shared publications between #{leaf.name} and #{root.name};<br/> " + 
   "MeSH similarity score: #{connection.mesh_tags_ic.round};" + " "
   #"<br/> tags: "+ trunc_and_join_array(root.tag_list & leaf.tag_list, 16, ", ", 4)
 end
