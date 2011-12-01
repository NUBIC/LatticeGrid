# sample d3 json structure:
#[{:name=>'flash', :size=>400, :imports=>["flash","javascript", "d3", "cytoscape"]},
# {:name=>'javascript', :size=>8000, :imports=>["d3", "cytoscape","javascript"]},
# {:name=>'d3', :size=>800, :imports=>["d3"]},
# {:name=>'cytoscape', :size=>400, :imports=>["cytoscape","javascript", "d3", "cytoscape"]}]

def d3_units_by_date_graph(units, start_date, end_date)
  graph_array = []
  investigator_array = []
  units.each do |unit|
    faculty_ids = unit.primary_or_member_faculty.map(&:id)
    next if faculty_ids.blank?
    graph_array << d3_unit_graph(unit)
    unit.primary_or_member_faculty.each do |investigator|
      graph_array << d3_unit_investigator_by_date_graph(unit, investigator, faculty_ids, start_date, end_date)
    end
  end
  return graph_array
end

def d3_all_units_graph(units)
  graph_array = []
  investigator_array = []
  units.each do |unit|
    faculty_ids = unit.primary_or_member_faculty.map(&:id)
    next if faculty_ids.blank?
    graph_array << d3_unit_graph(unit)
    unit.primary_or_member_faculty.each do |investigator|
      graph_array << d3_unit_investigator_graph(unit, investigator, faculty_ids)
      
#      if investigator_array.include?(investigator.username)
#        graph_array << d3_simple_unit_investigator_graph(unit, investigator)
#      else
#        investigator_array << investigator.username
#        graph_array << d3_unit_investigator_graph(unit, investigator, faculty_ids)
#      end
    end
  end
  return graph_array
end
  
def d3_master_unit_graph(units, master_unit)
  graph_array = []
  investigator_array = []
  faculty_ids = master_unit.primary_or_member_faculty.map(&:id)
  graph_array << d3_unit_graph(master_unit)
  master_unit.primary_or_member_faculty.each do |investigator|
    investigator_array << investigator.username
    graph_array << d3_unit_investigator_graph(master_unit, investigator, faculty_ids)
  end
  units.each do |unit|
    if unit.id != master_unit.id
      faculty_ids = unit.all_primary_or_member_faculty.map(&:id)
      next if faculty_ids.blank?
      graph_array << d3_unit_graph(unit)
      unit.all_primary_or_member_faculty.each do |investigator|
        if investigator_array.include?(investigator.username)
          graph_array << d3_simple_unit_investigator_graph(unit, investigator)
        else
          investigator_array << investigator.username
          graph_array << d3_unit_investigator_graph(unit, investigator, faculty_ids)
        end
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
    :size=>investigator.total_publications, 
    :imports=>[''] 
  } 
end

def d3_unit_investigator_graph(unit, investigator, faculty_ids)
  {
    :name => unit.abbreviation + "." + investigator.username,
    :size=>investigator.total_publications, 
    :imports=> d3_unit_investigator_imports(unit, investigator, faculty_ids)
  } 
end

def d3_unit_investigator_imports(unit, investigator, faculty_ids)
  the_arry = []
  return [''] if investigator.co_authors.length < 1
  investigator.co_authors.each do |co_author|
    if faculty_ids.include?(co_author.colleague_id)
      the_arry << unit.abbreviation + "." + co_author.colleague.username
    else
      the_arry << co_author.colleague.appointments[0].abbreviation + "." + co_author.colleague.username if co_author.colleague.appointments.length > 0
    end
  end
  return [''] if the_arry.blank?
  return the_arry
end

def d3_unit_investigator_by_date_graph(unit, investigator, faculty_ids, start_date, end_date)
  {
    :name => unit.abbreviation + "." + investigator.username,
    :size=>investigator.total_publications, 
    :imports=> d3_unit_investigator_by_date_imports(unit, investigator, faculty_ids, start_date, end_date)
  } 
end

def d3_unit_investigator_by_date_imports(unit, investigator, faculty_ids, start_date, end_date)
  the_arry = []
  return [''] if investigator.co_authors.length < 1
  abstract_ids = investigator.abstracts.abstracts_by_date(start_date, end_date).map(&:id)
  unless abstract_ids.blank?
    abstract_ids = abstract_ids.join(",").split(",")  # need this to make the ids strings vs an array of integers
    investigator.co_authors.each do |co_author|
      incommon_ids =  co_author.publication_list.split(",") & abstract_ids
      unless incommon_ids.blank?
        if faculty_ids.include?(co_author.colleague_id) 
          the_arry << unit.abbreviation + "." + co_author.colleague.username
        else
          the_arry << co_author.colleague.appointments[0].abbreviation + "." + co_author.colleague.username if co_author.colleague.appointments.length > 0 # skip people with no current appointment
        end
      end
    end
  end
  return [''] if the_arry.blank?
  return the_arry
end
