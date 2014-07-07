def generate_cytoscape_schema()
{
    :nodes => [{:name => "label", :type => "string"}, {:name => "element_type", :type => "string"}, {:name => "tooltiptext", :type => "string"}, {:name => "weight", :type => "number"}, {:name => "depth", :type => "number"}, {:name => "mass", :type => "long"} ],
    :edges => [{:name => "label", :type => "string"}, {:name => "element_type", :type => "string"}, {:name => "tooltiptext", :type => "string"}, {:name => "weight", :type => "long"}, {:name => "directed", :type => "boolean", :defValue => true} ]
}
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

def cytoscape_edge_hash(edge_index, source_index, target_index, label="edge", weight=1, tooltiptext="", element_type="Investigator")
  {
    :id => edge_index.to_s,
    :label => "#{label}",
    :tooltiptext => tooltiptext,
    :source => source_index,
    :target => target_index,
    :weight  => weight,
    :element_type => element_type
  }
end

def cytoscape_investigator_node_hash(investigator, weight=10, depth=1,investigator_awards=nil, investigator_studies=nil)
 {
   :id => investigator.id.to_s,
   :element_type => "Investigator",
   :label => investigator.name,
   :weight => weight,
   :mass => weight,
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
    "depth: #{depth}; <br/>" +
    (investigator_awards.blank? ? "" : "PI awards: $#{award_info(investigator_awards,'pd/pi')}; <br/>") +
    (investigator_awards.blank? ? "" : "All awards: $#{award_info(investigator_awards)}; <br/>") + 
    (investigator_studies.blank? ? "" : "Research studies: #{investigator_studies.length}; <br/>") + 
    ((investigator.home_department.blank?) ? "" : "primary appointment: #{investigator.home_department.abbreviation || truncate_words(investigator.home_department.name,30)}; <br/>") + 
    ((investigator.memberships.blank?) ? "" : "memberships: #{investigator.memberships.collect{|org| org.abbreviation || truncate_words(org.name,30) }.join(', <br/>&nbsp; &nbsp; &nbsp; &nbsp; ')}")
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
