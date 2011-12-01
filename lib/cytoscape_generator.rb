require 'graph_generator'

def generate_cytoscape_schema()
{
    :nodes => [{:name => "label", :type => "string"}, {:name => "tooltiptext", :type => "string"}, {:name => "weight", :type => "number"}, {:name => "depth", :type => "number"} ],
    :edges => [{:name => "label", :type => "string"}, {:name => "edge_type", :type => "string"}, {:name => "tooltiptext", :type => "string"}, {:name => "weight", :type => "number"}, {:name => "directed", :type => "boolean", :defValue => true} ]
}
end

def generate_cytoscape_data(investigator, max_depth)
  node_array_hash = generate_cytoscape_nodes(investigator, max_depth)
{
    :nodes => node_array_hash,
    :edges => generate_cytoscape_edges(investigator, max_depth, node_array_hash)
}
end

def generate_cytoscape_org_data(org, max_depth)
  node_array_hash = generate_cytoscape_org_nodes(org, max_depth)
{
    :nodes => node_array_hash,
    :edges => generate_cytoscape_org_edges(org, max_depth, node_array_hash)
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
    node_array = generate_cytoscape_nodes(investigator, depth, node_array, depth ) unless cytoscape_array_has_key?(node_array, investigator.id)
  end
  if max_depth > depth
    # second iteration - go deeper
    org.all_primary_or_member_faculty.each do |investigator|
      node_array = generate_cytoscape_nodes(investigator, max_depth, node_array, depth ) 
    end
  end
  node_array
end

def generate_cytoscape_nodes(investigator, max_depth, node_array=[], depth=0)
  #         nodes: [ { id: "n1", label: "Node 1", score: 1.0 },
  #                  { id: "n2", label: "Node 2", score: 2.2 },
  #                  { id: "n3", label: "Node 3", score: 3.5 } ]
  return node_array if investigator.blank?
  if depth == 0
    max_weight=max_colleague_pubs(investigator)+10
  else
    max_weight = investigator.total_publications
  end
  node_array << cytoscape_investigator_node_hash(investigator, max_weight, depth ) unless cytoscape_array_has_key?(node_array, investigator.id)
  depth +=1
  return node_array if depth > max_depth
  investigator.co_authors.each { |connection| 
    node_array << cytoscape_investigator_node_hash(connection.colleague, connection.colleague.total_publications, depth) unless cytoscape_array_has_key?(node_array, connection.colleague_id)
  }
  if max_depth > depth
    investigator.co_authors.each { |connection| 
      node_array = generate_cytoscape_nodes(connection.colleague, max_depth, node_array, depth)
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
   :label => org.name,
   :weight => weight,
   :depth => depth,
   :tooltiptext => org.abbreviation || org.name
 }
end

def cytoscape_investigator_node_hash(investigator, weight=10, depth=1,investigator_awards=nil, investigator_studies=nil)
 {
   :id => investigator.id.to_s,
   :label => investigator.name,
   :weight => weight,
   :depth => depth,
   :tooltiptext => investigator_tooltip(investigator, depth, investigator_awards, investigator_studies)
 }
end

def investigator_tooltip(investigator, depth, investigator_awards=nil, investigator_studies=nil)
    "Publications: #{investigator.total_publications}; <br/>" + 
    "First author pubs: #{investigator.num_first_pubs}; <br/>" +
    "Last author pubs: #{investigator.num_last_pubs}; <br/>" +
    "intra-unit collab: #{investigator.num_intraunit_collaborators}; <br/>" +
    "inter-unit collabs: #{investigator.num_extraunit_collaborators}; <br/>" +
    "username: #{investigator.username}; <br/>" +
    (investigator_awards.blank? ? "" : "PI awards: $#{award_info(investigator_awards,'pd/pi')}; <br/>") +
    (investigator_awards.blank? ? "" : "All awards: $#{award_info(investigator_awards)}; <br/>") + 
    (investigator_studies.blank? ? "" : "Research studies: #{investigator_studies.length}; <br/>") + 
    ((investigator.home_department.blank?) ? "" : "primary appointment: #{investigator.home_department.abbreviation || truncate_words(investigator.home_department.name,30)}; <br/>") + 
    ((investigator.memberships.blank?) ? "" : "memberships: #{investigator.memberships.collect{|org| org.abbreviation || truncate_words(org.name,30) }.join(', <br/>&nbsp; &nbsp; &nbsp; &nbsp; ')}")
end

def generate_cytoscape_org_edges(org, depth, nodes_array_hash,edge_array=[], include_intra_node_connections=false)
  org_index = org.name
  org.all_primary_or_member_faculty.each do |investigator|
    investigator_index = investigator.id.to_s
    edge_array << cytoscape_edge_hash(edge_array.length, org_index, investigator_index, "", 1, "member of #{org_index}", "org")
    edge_array = generate_cytoscape_edges(investigator, depth, nodes_array_hash, edge_array, include_intra_node_connections)
  end
  edge_array
end

def generate_cytoscape_edges(investigator, depth, nodes_array_hash, edge_array=[], include_intra_node_connections=false)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  investigator_index = investigator.id.to_s
  investigator.co_authors.each { |connection| 
    colleague_index = connection.colleague_id.to_s
    next unless colleague_index and cytoscape_array_has_key?(nodes_array_hash, colleague_index)
    if colleague_index and ! cytoscape_edge_array_has_key?(edge_array, colleague_index, investigator_index)
      tooltiptext=investigator_colleague_edge_tooltip(connection,investigator,connection.colleague)
      edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, colleague_index, connection.publication_cnt.to_s, connection.publication_cnt, tooltiptext, "publications")
      # go one more layer down to add all the intermediate edges
      if include_intra_node_connections
        connection.colleague.co_authors.each { |cc|
          cc_index = cc.colleague_id.to_s
          if cc_index and cytoscape_array_has_key?(nodes_array_hash, cc_index) and ! cytoscape_edge_array_has_key?(edge_array, colleague_index, cc_index)
            tooltiptext=investigator_colleague_edge_tooltip(cc,connection.colleague,cc.colleague)
            edge_array << cytoscape_edge_hash(edge_array.length, colleague_index, cc_index, cc.publication_cnt.to_s, cc.publication_cnt, tooltiptext, "publications")
          end
        }
      end
    end
    if (depth > 1)
      edge_array = generate_cytoscape_edges(connection.colleague, (depth-1), nodes_array_hash, edge_array, include_intra_node_connections)
    end
  }
  edge_array
end

 def cytoscape_edge_hash(edge_index, source_index, target_index, label="edge", value=1, tooltiptext="", edge_type="line")
   {
     :id => edge_index.to_s,
     :label => "#{label}",
     :tooltiptext => tooltiptext,
     :source => source_index,
     :target => target_index,
     :weight  => value,
     :edge_type => edge_type
   }
 end

 def investigator_colleague_edge_tooltip(connection, root, leaf)
   "#{connection.publication_cnt} shared publications between #{leaf.name} and #{root.name};<br/> " + 
   "MeSH similarity score: #{connection.mesh_tags_ic.round};" + " "
   #"<br/> tags: "+ trunc_and_join_array(root.tag_list & leaf.tag_list, 16, ", ", 4)
 end

def cytoscape_array_has_key?(head_array, key)
  head_array.each { |element|
    return true if element[:id].to_s == key.to_s
  }
  return false
end

def cytoscape_edge_array_has_key?(edge_array, idx1, idx2)
  edge_array.each { |element|
    return true if element[:source] == idx1 and element[:target] == idx2
    return true if element[:source] == idx2 and element[:target] == idx1
  }
  return false
end

def generate_cytoscape_award_data(investigator, max_depth)
    node_array_hash = generate_cytoscape_award_nodes(investigator, max_depth)
  {
      :nodes => node_array_hash,
      :edges => generate_cytoscape_award_edges(investigator, max_depth, node_array_hash)
  }
end

def generate_cytoscape_study_data(investigator, max_depth)
    node_array_hash = generate_cytoscape_study_nodes(investigator, max_depth)
  {
      :nodes => node_array_hash,
      :edges => generate_cytoscape_study_edges(investigator, max_depth, node_array_hash)
  }
end

def cytoscape_study_node_hash(study, weight=10, depth=1)
 {
   :id => "S_#{study.id}",
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


def generate_cytoscape_study_edges(investigator, depth, nodes_array_hash, edge_array=[], include_intra_node_connections=false)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  investigator_index = investigator.id.to_s
  investigator.investigator_studies.each { |i_study| 
    study_index = "S_#{i_study.study_id}"
    if study_index and ! cytoscape_edge_array_has_key?(edge_array, study_index, investigator_index)
      tooltiptext=investigator_study_edge_tooltip(i_study,investigator,depth)
      edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, study_index, i_study.role, i_study.study.investigator_studies.length, tooltiptext, "studies")
      # now add all the investigator - study connections
      edge_array = generate_cytoscape_study_investigator_edges(i_study.study,edge_array,depth)
      # go one more layer down to add all the intermediate edges
      if include_intra_node_connections
        i_study.study.investigator_studies.each { |inv_study|
          inv_study_index = inv_study.investigator_id.to_s
          if inv_study_index and cytoscape_array_has_key?(nodes_array_hash, inv_study_index) and ! cytoscape_edge_array_has_key?(edge_array, study_index, inv_study_index)
            unless inv_study.investigator.blank?
              tooltiptext=investigator_study_edge_tooltip(i_study,inv_study.investigator,depth)
              edge_array << cytoscape_edge_hash(edge_array.length, study_index, inv_study_index, inv_study.role, i_study.study.investigator_studies.length, tooltiptext, "studies")
            end
          end
        }
      end
    end
    if (depth > 1)
      i_study.proposal.investigators.each { |inv| 
        edge_array = generate_cytoscape_study_edges(inv, (depth-1), nodes_array_hash, edge_array, include_intra_node_connections)
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
        edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, study_index, inner_inv_study.role, study.investigator_studies.length, tooltiptext, "studies")
      end
    end
  }
  edge_array
end


def investigator_study_edge_tooltip(i_study,investigator,depth)
   "Investigator #{investigator.name}; <br/>" + 
   "Role: #{i_study.role}; <br/>" + 
   "Study: #{i_study.study.title}; <br/>" 
end

def study_weight(value)
  case value.to_i
  when 1..200000
    value
  else
    1
  end

end


def cytoscape_award_node_hash(award, weight=10, depth=1)
 {
   :id => "A_#{award.id}",
   :label => award.institution_award_number,
   :weight => award_weight(weight),
   :depth => depth,
   :tooltiptext => award_tooltip(award, depth)
 }
end

def award_tooltip(award, depth)
  "Title: #{truncate_words(award.title,50)}; <br/>" + 
  "OR Award id: #{award.institution_award_number}; <br/>" + 
  "Award number: #{award.sponsor_award_number}; <br/>" + 
  "Award start: #{award.award_start_date.to_s}; <br/>" + 
  "Award end: #{award.award_end_date.to_s}; <br/>" + 
  "Project start: #{award.project_start_date.to_s}; <br/>" + 
  "Project end: #{award.project_end_date.to_s}; <br/>" + 
  "Amount: #{number_to_humanized(award.total_amount)}; <br/>" +
    "Sponsor: #{award.sponsor_name}; <br/>" +
    "Sponsor type: #{award.sponsor_type_name}; <br/>" +
    ((award.investigator_proposals.blank?) ? "" : "Collaborators: #{award.investigator_proposals.length}; <br/>" )
end


def generate_cytoscape_award_nodes(investigator, max_depth, node_array=[], depth=0)
  #         nodes: [ { id: "n1", label: "Node 1", score: 1.0 },
  #                  { id: "n2", label: "Node 2", score: 2.2 },
  #                  { id: "n3", label: "Node 3", score: 3.5 } ]
  node_array << cytoscape_investigator_node_hash(investigator, 75, depth, investigator.investigator_proposals ) unless cytoscape_array_has_key?(node_array, investigator.id)
  depth +=1
  investigator.proposals.each { |award| 
    node_array << cytoscape_award_node_hash(award, award.total_amount, depth) unless cytoscape_array_has_key?(node_array, "A_#{award.id}")
    award.investigators.each { |award_investigator|
      node_array << cytoscape_investigator_node_hash(award_investigator, 55, depth, award_investigator.investigator_proposals ) unless cytoscape_array_has_key?(node_array, award_investigator.id)
    }
  }
  if max_depth > depth
    investigator.proposals.each { |award| 
      award.investigators.each { |award_investigator|
        node_array = generate_cytoscape_award_nodes(award_investigator, max_depth, node_array, depth)
      }
    }
  end
  node_array
end


def generate_cytoscape_award_edges(investigator, depth, nodes_array_hash, edge_array=[], include_intra_node_connections=false)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  investigator_index = investigator.id.to_s
  investigator.investigator_proposals.each { |i_award| 
    award_index = "A_#{i_award.proposal_id}"
    if award_index and ! cytoscape_edge_array_has_key?(edge_array, award_index, investigator_index)
      tooltiptext=investigator_award_edge_tooltip(i_award,investigator,depth)
      edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, award_index, i_award.role, i_award.proposal.total_amount, tooltiptext, "awards")
      # now add all the investigator - award connections
      edge_array = generate_cytoscape_award_investigator_edges(i_award.proposal,edge_array,depth)
      # go one more layer down to add all the intermediate edges
      if include_intra_node_connections
        i_award.proposal.investigator_proposals.each { |inv_award|
          inv_award_index = inv_award.investigator_id.to_s
          if inv_award_index and cytoscape_array_has_key?(nodes_array_hash, inv_award_index) and ! cytoscape_edge_array_has_key?(edge_array, award_index, inv_award_index)
            tooltiptext=investigator_award_edge_tooltip(i_award,inv_award.investigator,depth)
            edge_array << cytoscape_edge_hash(edge_array.length, award_index, inv_award_index, inv_award.role, i_award.proposal.total_amount, tooltiptext, "awards")
          end
        }
      end
    end
    if (depth > 1)
      i_award.proposal.investigators.each { |inv| 
        edge_array = generate_cytoscape_award_edges(inv, (depth-1), nodes_array_hash, edge_array, include_intra_node_connections)
      }
    end
  }
  edge_array
end

def generate_cytoscape_award_investigator_edges(award,edge_array, depth)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  award_index = "A_#{award.id}"
  award.investigator_proposals.each { |inner_inv_award| 
    investigator_index = inner_inv_award.investigator_id.to_s
    
    if investigator_index and ! cytoscape_edge_array_has_key?(edge_array, award_index, investigator_index)
      unless inner_inv_award.investigator.blank?
        tooltiptext=investigator_award_edge_tooltip(inner_inv_award,inner_inv_award.investigator,depth)
        edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, award_index, inner_inv_award.role, award.total_amount, tooltiptext, "awards")
      end
    end
  }
  edge_array
end


def investigator_award_edge_tooltip(i_award,investigator,depth)
   "Investigator #{investigator.name unless investigator.blank?}; <br/>" + 
   "Role: #{i_award.role}; <br/>" + 
   "Award: #{i_award.proposal.title}; <br/>" 
end

def award_weight(value)
  value = 1 if value.blank?
  value = 1 if value.to_i.blank?
  value = value.to_i/100000
  # value is in 100K increments
  case value.to_i
  when 400..200000
    220
  when 200..400
    180
  when 100..200
    150
  when 50..100
    80
  when 25..50
    50
  when 10..25
    35
  when 5..10
    25
  else
    10
  end

end

def current_award_info(investigator_awards,role="", split_allocations=false)
  return "" if investigator_awards.blank? or investigator_awards.length < 1
  total = award_total(investigator_awards,role, Date.today, split_allocations)
  number_to_humanized(total)
end

def award_info(investigator_awards,role="", split_allocations=false)
  return "" if investigator_awards.blank? or investigator_awards.length < 1
  total = award_total(investigator_awards,role, "", split_allocations)
  number_to_humanized(total)
end

def award_total(investigator_awards,role="", by_date="", split_allocations=false)
  total = 0
  if !role.blank? and role.class.to_s =~ /string/i
    role = role.split(",")
  end
  investigator_awards.each { |inv_award|
    if role.blank? or (!inv_award.role.blank? and role.include?(inv_award.role.downcase)) 
      if by_date.blank? or inv_award.proposal.project_end_date.blank? or inv_award.proposal.project_end_date >= by_date
        this_total = inv_award.proposal.total_amount.to_i
        this_total = this_total/inv_award.proposal.investigator_proposals.count if split_allocations
        total+= this_total
      end
    end
  }
  total
end

def number_to_humanized(amount)
  case amount.to_i
  when 1..10000
    amount
  when 10000..500000
    "#{(amount.to_i/100).to_f/10} thousand"
  when 500000..5000000
    "#{(amount.to_i/10000).to_f/100} million"
  when 5000000..500000000
    "#{(amount.to_i/100000).to_f/10} million"
  when 500000000..5000000000000
    "#{(amount.to_i/100000000).to_f/10} billion"
  else
    amount
  end
end
