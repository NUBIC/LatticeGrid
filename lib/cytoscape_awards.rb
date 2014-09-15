require 'cytoscape_utilities'

def cytoscape_award_node_hash(award, weight=10, depth=1)
  {
    :id => "A_#{award.id}",
    :element_type => "Award",
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
  "depth: #{depth}; <br/>" +
    "Sponsor: #{award.sponsor_name}; <br/>" +
    "Sponsor type: #{award.sponsor_type_name}; <br/>" +
    ((award.investigator_proposals.blank?) ? "" : "Collaborators: #{award.investigator_proposals.length}; <br/>" )
end

def generate_cytoscape_award_nodes(investigator, max_depth, node_array=[], depth=0)
  #         nodes: [ { id: "n1", label: "Node 1", score: 1.0 },
  #                  { id: "n2", label: "Node 2", score: 2.2 },
  #                  { id: "n3", label: "Node 3", score: 3.5 } ]
  unless cytoscape_array_has_key?(node_array, investigator.id)
    node_array << cytoscape_investigator_node_hash(investigator, 75, depth, investigator.investigator_proposals)
  end
  depth += 1

  investigator.proposals.each do |award|
    unless cytoscape_array_has_key?(node_array, "A_#{award.id}")
      node_array << cytoscape_award_node_hash(award, award.total_amount, depth)
    end
    award.investigators.each do |award_investigator|
      unless cytoscape_array_has_key?(node_array, award_investigator.id)
        node_array << cytoscape_investigator_node_hash(award_investigator, 55, depth, award_investigator.investigator_proposals)
      end
    end
  end
  if max_depth > depth
    investigator.proposals.each do |award|
      award.investigators.each do |award_investigator|
        node_array = generate_cytoscape_award_nodes(award_investigator, max_depth, node_array, depth)
      end
    end
  end
  node_array
end

def generate_cytoscape_award_edges(investigator, depth, node_array, edge_array=[], include_intra_node_connections=false)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  investigator_index = investigator.id.to_s
  investigator.investigator_proposals.each do |i_award|
    award_index = "A_#{i_award.proposal_id}"
    next if i_award.proposal.blank?
    if award_index && !cytoscape_edge_array_has_key?(edge_array, award_index, investigator_index) && cytoscape_array_has_key?(node_array, award_index)

      tooltiptext = investigator_award_edge_tooltip(i_award,investigator,depth)
      edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, award_index, i_award.role, i_award.proposal.investigator_proposals.length, tooltiptext, "Award")
      # now add all the investigator - award connections
      edge_array = generate_cytoscape_award_investigator_edges(i_award.proposal, edge_array, depth)

      # go one more layer down to add all the intermediate edges
      if include_intra_node_connections
        i_award.proposal.investigator_proposals.each do |inv_award|
          inv_award_index = inv_award.investigator_id.to_s
          if inv_award_index && cytoscape_array_has_key?(node_array, inv_award_index) && !cytoscape_edge_array_has_key?(edge_array, award_index, inv_award_index)
            tooltiptext = investigator_award_edge_tooltip(i_award, inv_award.investigator, depth)
            edge_array << cytoscape_edge_hash(edge_array.length, award_index, inv_award_index, inv_award.role, i_award.proposal.investigator_proposals.length, tooltiptext, "Award")
          end
        end
      end
    end
    if (depth > 1)
      i_award.proposal.investigators.each do |inv|
        edge_array = generate_cytoscape_award_edges(inv, (depth-1), node_array, edge_array, include_intra_node_connections)
      end
    end
  end
  edge_array
end

def generate_cytoscape_award_investigator_edges(award,edge_array, depth)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  award_index = "A_#{award.id}"
  award.investigator_proposals.each do |inner_inv_award|
    investigator_index = inner_inv_award.investigator_id.to_s

    if investigator_index && !cytoscape_edge_array_has_key?(edge_array, award_index, investigator_index)
      unless inner_inv_award.investigator.blank?
        tooltiptext = investigator_award_edge_tooltip(inner_inv_award,inner_inv_award.investigator,depth)
        edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, award_index, inner_inv_award.role, inner_inv_award.proposal.investigator_proposals.length, tooltiptext, "Award")
      end
    end
  end
  edge_array
end

def investigator_award_edge_tooltip(i_award, investigator, depth)
  "Investigator #{investigator.name unless investigator.blank?}; <br/>" +
  "Role: #{i_award.role}; <br/>" +
  "Award: #{i_award.proposal.title}; <br/>"
end

def award_weight(value)
  value = 1 if value.blank?
  value = 1 if value.to_i.blank?
  value = value.to_i / 100_000
  # value is in 100K increments
  case value.to_i
  when 400..4_000_000
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

# TODO: determine if this method is used
def award_edge_weight(value)
  value = award_weight(value) / 10
end

def current_award_info(investigator_awards, role = '', split_allocations = false)
  return '' if investigator_awards.blank? || investigator_awards.length < 1
  total = award_total(investigator_awards, role, Date.today, split_allocations)
  number_to_humanized(total)
end

def award_info(investigator_awards, role = '', split_allocations = false)
  return '' if investigator_awards.blank? || investigator_awards.length < 1
  total = award_total(investigator_awards, role, '', split_allocations)
  number_to_humanized(total)
end

def award_total(investigator_awards, role = '', by_date = '', split_allocations = false)
  total = 0
  role = role.split(',') if !role.blank? && role.class.to_s =~ /string/i
  investigator_awards.each do |inv_award|
    if role.blank? || (!inv_award.role.blank? && role.include?(inv_award.role.downcase))
      if by_date.blank? || inv_award.proposal.project_end_date.blank? || inv_award.proposal.project_end_date >= by_date
        this_total = inv_award.proposal.total_amount.to_i
        this_total = this_total / inv_award.proposal.investigator_proposals.count if split_allocations
        total += this_total
      end
    end
  end
  total
end
