# sample d3 json structure for tree layout:
## {id=>"53xyz", :name=>'d3', :size=>800, :summary:"", :firstName=>"", :lastName=>"", 
#     :organization=>"", :keywords="", :publications=>"", :children=>["d3"]},

# sample d3 json structure for force layout:
# {:nodes:[{id=>"53xyz", :name=>'d3', :size=>800, :summary:"", :firstName=>"", :lastName=>"", 
#     :organization=>"", :keywords="", :publications=>""}], :links: [{:source: id_source, :target: id_target, :value: val}]

def d34_investigator_force_graph(investigator, levels=2)
  if investigator.blank? 
    return ''
  end
  # coauthor_ids = investigator.co_authors.map(&:colleague_id)
  nodal =  d34_investigator_nodes(investigator, levels, {:nodes=>[],:included_ids=>[]})
  # debug: logger.warn "included_ids: " + nodal[:included_ids].inspect
  return { 
    :nodes => nodal[:nodes],
    :links => d34_investigator_links(investigator, levels, [], nodal[:included_ids], [])
  }
end

def d34_investigator_nodes(investigator, levels, nodal) 
  nodes = nodal[:nodes]
  included_ids = nodal[:included_ids]
  
  unless included_ids.include?(investigator.id)
    nodes << d34_investigator_node(investigator)
    included_ids << investigator.id
  end
  investigator.colleague_coauthors.each do |colleague|
    unless included_ids.include?(colleague.id)
      nodes << d34_investigator_node(colleague)
      included_ids << colleague.id
    end
    unless levels < 2
      nodal = d34_investigator_nodes(colleague, levels-1,  {:nodes=>nodes, :included_ids=>included_ids}) 
      nodes = nodal[:nodes]
      included_ids = nodal[:included_ids]
    end
  end
  return {:nodes=>nodes, :included_ids=>included_ids}
end

def d34_investigator_links(investigator, levels, included_ids, included_node_ids, links) 
  investigator.colleague_coauthors.each do |colleague|
    the_link_id = ( investigator.id < colleague.id) ? investigator.id.to_s+' '+colleague.id.to_s : colleague.id.to_s+' '+ investigator.id.to_s
    unless included_ids.include?(the_link_id)
      target = included_node_ids.index(investigator.id)
      source = included_node_ids.index(colleague.id)
      unless target.blank? or source.blank?
        links << d34_investigators_link(source, target, 1)
        included_ids << the_link_id
      end
    end
    unless levels < 2
      links = d34_investigator_links(colleague, levels-1, included_ids, included_node_ids, links) 
    end
  end
  return links
end


def d34_investigator_node(investigator)
  {
    :id => investigator.username,
    :name => investigator.full_name,
    :username => investigator.username,
    :firstName => investigator.first_name,
    :lastName => investigator.last_name,
    :summary => (( 0==1 ) ? "" : investigator.faculty_research_summary),
    :size => investigator.total_publications, 
    :publications => investigator.total_publications, 
    :keywords => (( 1==1 ) ? "" : investigator.tag_list),
    :organization => investigator.organization_title
  }
end 

def d34_investigators_link(source, target, value)
  {
    :source => source,
    :target => target,
    :value => value
  }
end 


def d34_investigator_tree_graph(investigator, levels=2)
  if investigator.blank? 
    return ''
  end
  # coauthor_ids = investigator.co_authors.map(&:colleague_id)
  nodal =  d34_investigator_tree_nodes(investigator, levels, {:nodes=>[],:included_ids=>[]})
  # debug: logger.warn "included_ids: " + nodal[:included_ids].inspect
  return nodal[:nodes]
end

def d34_investigator_tree_nodes(investigator, levels, nodal) 
  nodes = nodal[:nodes]
  the_children = []
  included_ids = nodal[:included_ids]
  
  unless included_ids.include?(investigator.id)
    nodes << d34_investigator_node(investigator)
    included_ids << investigator.id
  end
  investigator.colleague_coauthors.each do |colleague|
    unless included_ids.include?(colleague.id)
      the_children << d34_investigator_node(colleague)
      included_ids << colleague.id
    end
  end
  investigator.colleague_coauthors.each do |colleague|
    unless levels < 2
      nodal = d34_investigator_tree_nodes(colleague, levels-1,  {:nodes=>the_children, :included_ids=>included_ids}) 
      the_children = nodal[:nodes]
      included_ids = nodal[:included_ids]
    end
  end
  nodes.map { |node| 
    if (node[:id] == investigator.username)  
      node[:children] = the_children 
    end
  }
  
  return {:nodes=>nodes, :included_ids=>included_ids}
end

