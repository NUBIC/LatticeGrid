def generate_protovis_nodes(investigator, depth, node_array=[])
  return node_array if investigator.blank? or investigator.name.blank?
  node_array << node_hash(investigator) if ! protovis_array_has_key?(node_array, investigator.id)
  investigator.co_authors.each { |connection| 
    if ! protovis_array_has_key?(node_array, connection.colleague_id)
      node_array << node_hash(connection.colleague) unless connection.colleague.blank?
    end
    if depth > 1
      node_array = generate_protovis_nodes(connection.colleague, depth-1, node_array)
    end
  }
  node_array
end

def generate_protovis_edges(investigator, nodes_array_hash, depth, edge_array=[])
  investigator_index = protovis_array_hash_index(nodes_array_hash, investigator.id)
  investigator.co_authors.each { |connection| 
    colleague_index = protovis_array_hash_index(nodes_array_hash, connection.colleague_id)
    if colleague_index and ! protovis_edge_array_has_key?(edge_array, colleague_index, investigator_index)
      edge_array << edge_hash(investigator_index, colleague_index, connection.publication_cnt)
    end
    if depth >= 1
      edge_array = generate_protovis_edges(connection.colleague, nodes_array_hash, depth-1, edge_array)
    end
  }
  edge_array
end

 def edge_hash(source_index, target_index, value)
   {
     :source => source_index,
     :target => target_index,
     :value  => value
   }
 end

 def node_hash(investigator)
   {
     :node_id => investigator.id,
     :nodeName => investigator.name,
     :group => (investigator.appointments.length == 0 ? 0 :investigator.appointments.first.id)
   }
 end

def protovis_array_has_key?(head_array, key)
  head_array.each { |element|
   return true if element[:node_id].to_s == key.to_s
  }
  return false
end

def protovis_edge_array_has_key?(edge_array, idx1, idx2)
  edge_array.each { |element|
    return true if element[:source] == idx1 and element[:target] == idx2
    return true if element[:source] == idx2 and element[:target] == idx1
  }
  return false
end

def protovis_array_hash_index(arry, key)
  arry.each_with_index { |element, idx |
   return idx if element[:node_id].to_s == key.to_s
  }
  return false
end
