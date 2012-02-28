require 'cytoscape_utilities'

#study node weight is number of studies

def cytoscape_study_node_hash(study, weight=10, depth=1)
 {
   :id => "S_#{study.id}",
   :element_type => "Study",
   :label => study.irb_study_number,
   :weight => study_weight(weight),
   :depth => depth,
   :tooltiptext => study_tooltip(study, depth)
 }
end

def study_tooltip(study, depth)
  "Title: #{truncate_words(study.title,50)}; <br/>" + 
  "eIRB STU: #{study.irb_study_number}; <br/>" + 
  "Approved : #{study.approved_date.to_s}; <br/>" + 
  "Status: #{study.status}; <br/>" + 
    "Type: #{study.research_type}; <br/>" +
    "Review: #{study.review_type}; <br/>" +
    "depth: #{depth}; <br/>" +
    ((study.investigator_studies.blank?) ? "" : "Collaborators: #{study.investigator_studies.length}; <br/>" )
end

def generate_cytoscape_study_nodes(investigator, max_depth, node_array=[], depth=0)
  #         nodes: [ { id: "n1", label: "Node 1", score: 1.0 },
  #                  { id: "n2", label: "Node 2", score: 2.2 },
  #                  { id: "n3", label: "Node 3", score: 3.5 } ]
  node_array << cytoscape_investigator_node_hash(investigator, 75, depth, nil, investigator.investigator_studies ) unless cytoscape_array_has_key?(node_array, investigator.id)
  depth +=1
  investigator.studies.each { |study| 
    node_array << cytoscape_study_node_hash(study, study.investigator_studies.length, depth) unless cytoscape_array_has_key?(node_array, "S_#{study.id}")
    study.investigators.each { |study_investigator|
      node_array << cytoscape_investigator_node_hash(study_investigator, 55, depth, nil, study_investigator.investigator_studies ) unless cytoscape_array_has_key?(node_array, study_investigator.id)
    }
  }
  if max_depth > depth
    investigator.studies.each { |study| 
      study.investigators.each { |study_investigator|
        node_array = generate_cytoscape_study_nodes(study_investigator, max_depth, node_array, depth)
      }
    }
  end
  node_array
end


def generate_cytoscape_study_edges(investigator, depth, node_array, edge_array=[], include_intra_node_connections=false)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  investigator_index = investigator.id.to_s
  investigator.investigator_studies.each { |i_study| 
    study_index = "S_#{i_study.study_id}"
    if study_index and ! cytoscape_edge_array_has_key?(edge_array, study_index, investigator_index) and cytoscape_array_has_key?(node_array, study_index)
      tooltiptext=investigator_study_edge_tooltip(i_study,investigator,depth)
      edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, study_index, i_study.role, i_study.study.investigator_studies.length, tooltiptext, "Study")
      # now add all the investigator - study connections
      edge_array = generate_cytoscape_study_investigator_edges(i_study.study,edge_array,depth)
      # go one more layer down to add all the intermediate edges
      if include_intra_node_connections
        i_study.study.investigator_studies.each { |inv_study|
          inv_study_index = inv_study.investigator_id.to_s
          if inv_study_index and cytoscape_array_has_key?(node_array, inv_study_index) and ! cytoscape_edge_array_has_key?(edge_array, study_index, inv_study_index)
            unless inv_study.investigator.blank?
              tooltiptext=investigator_study_edge_tooltip(i_study,inv_study.investigator,depth)
              edge_array << cytoscape_edge_hash(edge_array.length, study_index, inv_study_index, inv_study.role, i_study.study.investigator_studies.length, tooltiptext, "Study")
            end
          end
        }
      end
    end
    if (depth > 1)
      i_study.study.investigators.each { |inv| 
        edge_array = generate_cytoscape_study_edges(inv, (depth-1), node_array, edge_array, include_intra_node_connections)
      }
    end
  }
  edge_array
end

def generate_cytoscape_study_investigator_edges(study,edge_array, depth)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  study_index = "S_#{study.id}"
  study.investigator_studies.each { |inner_inv_study| 
    investigator_index = inner_inv_study.investigator_id.to_s
    
    if investigator_index and ! cytoscape_edge_array_has_key?(edge_array, study_index, investigator_index)
      unless inner_inv_study.investigator.blank?
        tooltiptext=investigator_study_edge_tooltip(inner_inv_study,inner_inv_study.investigator,depth)
        edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, study_index, inner_inv_study.role, study.investigator_studies.length, tooltiptext, "Study")
      end
    end
  }
  edge_array
end


def investigator_study_edge_tooltip(i_study,investigator,depth)
   "Investigator #{investigator.name}; <br/>" + 
   "Role: #{i_study.role}; <br/>" + 
   "Study: #{truncate_words(i_study.study.title, 50)}; <br/>" 
end

def study_weight(value)
  case value.to_i
  when 1..200000
    value
  else
    1
  end

end
