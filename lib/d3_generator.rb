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
    end
  end
  return graph_array
end

def d3_all_investigators_graph(program=nil)
  if program.blank?
    investigators = Investigator.by_name
  else
    investigators = program.all_primary_or_member_faculty.sort_by(&:last_name)
  end
  if investigators.blank?
    return ['']
  end
  graph_array = []
  coauthor_ids = investigators.map(&:id)
  investigators.each do |master_investigator|
    graph_array << d3_investigator_graph(master_investigator, coauthor_ids, master_investigator.last_name)
  end
  return graph_array
end

def d3_master_investigator_graph(investigator)
  if investigator.blank?
    return ['']
  end
  coauthor_ids = investigator.co_authors.map(&:colleague_id)
  return add_investigator_to_graph(investigator,coauthor_ids, [])
end

def add_investigator_to_graph(investigator,coauthor_ids, graph)
  name = investigator.last_name
  graph << d3_investigator_graph(investigator, coauthor_ids, name)
  investigator.colleague_coauthors.each do |colleague|
    graph << d3_investigator_graph(colleague, coauthor_ids, name) if colleague
  end
  return graph
end

def d3_all_investigators_bundle(investigators)
  graph_array = []
  investigators.each do |investigator|
    begin
      org_unit = OrganizationalUnit.find(investigator.unit_list.first)
    rescue ActiveRecord::RecordNotFound
      # noop
      org_unit = nil
    end
    org_unit = org_unit.blank? ? 'undefined' : org_unit.abbreviation.to_s
    edge = d3_investigator_edge(investigator, org_unit)
    graph_array << edge unless (edge[:size] == 0)
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

def d3_investigator_graph(investigator, coauthor_ids, primary_name)
  {
    :name => investigator.last_name,
    :size => investigator.total_publications,
    :imports => d3_investigator_imports(investigator, coauthor_ids, primary_name)
  }
end

def d3_investigator_edge(investigator, org_unit)
  first = investigator.first_name.delete("\'")
  first = first.delete("(")
  first = first.delete(")")
  first = first.delete(".")
  {
    :name => "RHLCCC." +  org_unit + "."  + first  + "-" + investigator.last_name.delete("\'"),
    :size => investigator.total_publications,
    :imports => d3_investigator_edge_imports(investigator)
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
      if co_author.colleague && co_author.colleague.appointments.length > 0
        the_arry << co_author.colleague.appointments[0].abbreviation + "." + co_author.colleague.username
      end
    end
  end
  return [''] if the_arry.blank?
  return the_arry
end

def d3_investigator_imports(investigator, coauthor_ids, primary_name)
  the_arry = []
  return [''] if investigator.colleague_coauthors.length < 1
  unless investigator.last_name.eql? primary_name
    the_arry << primary_name
  end
  investigator.colleague_coauthors.each do |colleague|
    next unless colleague
    if coauthor_ids.include?(colleague.id)
      the_arry << colleague.last_name
    end
  end
  return the_arry
end

def d3_investigator_edge_imports(investigator)
  the_arry = []
  return [] if investigator.colleague_coauthors.length < 1
  investigator.colleague_coauthors.each do |colleague|
    next unless colleague
    begin
      org_unit = OrganizationalUnit.find(colleague.unit_list.first)
    rescue ActiveRecord::RecordNotFound
      # noop
      org_unit = nil
    end
    if org_unit.blank?
      break
    else
      org_unit = org_unit.abbreviation.to_s
    end
    first = colleague.first_name.delete("\'")
    first = first.delete("(")
    first = first.delete(")")
    first = first.delete(".")
    the_arry << "RHLCCC." + org_unit.to_s + "." + first + "-" + colleague.last_name.delete("\'")
  end
  the_arry.blank? ? [] : the_arry
end

def d3_unit_investigator_by_date_graph(unit, investigator, faculty_ids, start_date, end_date)
  {
    :name => unit.abbreviation + "." + investigator.username,
    :size => investigator.total_publications,
    :imports => d3_unit_investigator_by_date_imports(unit, investigator, faculty_ids, start_date, end_date)
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
