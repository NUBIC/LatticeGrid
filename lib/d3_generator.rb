# sample d3 json structure:
#[{:name=>'flash', :size=>400, :imports=>["flash","javascript", "d3", "cytoscape"]},
# {:name=>'javascript', :size=>8000, :imports=>["d3", "cytoscape","javascript"]},
# {:name=>'d3', :size=>800, :imports=>["d3"]},
# {:name=>'cytoscape', :size=>400, :imports=>["cytoscape","javascript", "d3", "cytoscape"]}]

def d3_units_graph(units)
  graph_array = []
  investigator_array = []
  units.each do |unit|
    graph_array << d3_unit_graph(unit)
    unit.associated_faculty.each do |investigator|
      if investigator_array.include?(investigator.username)
        graph_array << d3_simple_unit_investigator_graph(unit, investigator)
      else
        investigator_array << investigator.username
        graph_array << d3_unit_investigator_graph(unit, investigator)
      end
    end
  end
  return graph_array
end
  
def d3_unit_graph(unit)
  {
    :name=>unit.abbreviation, 
    :size=>unit.abstracts.count, 
    :imports=>[''] 
  }
end

def d3_simple_unit_investigator_graph(unit, investigator)
  {
    :name => unit.abbreviation + "." + investigator.username,
    :size=>investigator.abstracts.count, 
    :imports=>[''] 
  } 
end

 def d3_unit_investigator_graph(unit, investigator)
   {
     :name => unit.abbreviation + "." + investigator.username,
     :size=>investigator.abstracts.count, 
     :imports=> investigator.co_authors.map{|inv| inv.colleague.appointments[0].abbreviation + "." + inv.colleague.username if inv.colleague.appointments.length > 0 }
   } 
 end
