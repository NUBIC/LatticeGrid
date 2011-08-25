def adjacencies(investigator, head_array=[], depth=0)
  depth+=1
  head_node_hash = head_node(investigator, depth)
  head_array << head_node_hash
  investigator.co_authors.each { |connection| 
    head_node_hash[:adjacencies] << adjacent_nodes( investigator, connection.colleague )
    if ! array_hash_has_key?(head_array, connection.colleague.id)
      if depth<2 
        head_array = adjacencies(connection.colleague, head_array, depth)
      else
        head_array << head_node(connection.colleague, depth)
      end
    end
  }
  head_array
end

 def adjacent_nodes(investigator,colleague)
   {
     :nodeTo => colleague.id,
     :nodeFrom => investigator.id,
     :data => {}
   }
 end

 def head_node(investigator, depth=1)
   color = "\#83548B"
   color = "\#FCD9A1" if depth > 1
   color = "\#555555" if depth > 2 
   {
     :id => investigator.id,
     :name => investigator.name,
     :data => {
       "\$color"=> color, 
       "\$type"=> "circle"
     },
     :adjacencies => []
   }
 end

def array_hash_has_key?(head_array, key)
  head_array.each { |element|
   return true if element[:id].to_s == key.to_s
  }
  return false
end
