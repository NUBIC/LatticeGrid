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


def d3_master_investigator_graph(investigator)
  graph_array = []
  master_investigator = investigator
  name = master_investigator.last_name
  coauthors = master_investigator.co_authors
  coauthor_ids = []
  if master_investigator.blank? 
    graph_array = ['']
    return graph_array
  end
  coauthors.each do |ca|
    coauthor_ids << ca.colleague_id
  end
  graph_array << d3_investigator_graph(master_investigator, coauthor_ids, name)
  master_investigator.colleague_coauthors.each do |colleague|
    graph_array << d3_investigator_graph(colleague, coauthor_ids, name)
  end
  return graph_array 
end


def d3_all_investigators_bundle(investigators)
  graph_array = []
  investigators.each do |investigator|
    org_unit = OrganizationalUnit.find_by_id(investigator.unit_list().first)
    if org_unit.blank?
      org_unit = "undefined"
    else 
      org_unit = org_unit.abbreviation.to_s
    end
    #unless (org_unit == "TIMA" or org_unit == "HM"  or org_unit == "CCB")
    #  graph_array << d3_investigator_edge(investigator, org_unit)
    #end
    edge = d3_investigator_edge(investigator, org_unit)
    unless (edge[:size] == 0)
      graph_array << edge
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
    #OrganizationalUnit.find_by_id(investigator.unit_list().first.to_s).abbreviation +
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
      the_arry << co_author.colleague.appointments[0].abbreviation + "." + co_author.colleague.username if co_author.colleague.appointments.length > 0
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
      if coauthor_ids.include?(colleague.id)
        the_arry <<   colleague.last_name
        #OrganizationalUnit.find_by_id(colleague.unit_list().first.to_s).abbreviation +  
      end
    end
    return the_arry
end


def d3_investigator_edge_imports(investigator)
    the_arry = []
    return [] if investigator.colleague_coauthors.length < 1 
    investigator.colleague_coauthors.each do |colleague|
        org_unit = OrganizationalUnit.find_by_id(colleague.unit_list().first)
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
    if the_arry.blank?
      return []
    end
    return the_arry
end


def d3_wordle_data(investigator)
  allwordshash = []
  allwords = "" 
    abstracts = investigator.abstracts.sort_by{|abstract| -abstract.year.to_i}
  if abstracts.length < 18
      abstracts.each { |abstract|
          allwords += " " + abstract.abstract
      }
  else
      for i in 0..18
          allwords += " " +  abstracts[i].abstract 
      end
  end

  allwords = allwords.delete(".,();:-<=/0-9")
  allwordsarray = allwords.split(' ')
  allwordsarray.map! {|word| word = word.downcase}
  possiblewords = allwordsarray.uniq
  generics = ["the", "of", "and", "as", "to", "a", "in", "that", "with", "for", "an", "at", "not", "by", "on", "but", "or", "from", "its", "when", "this", "these", "i", "was", "is", "we", "have", "some", "into", "may", "well", "there", 
    "our", "it", "me", "you", "what", "which", "who", "whom", "those", "are", "were", "be", "however","been", "being", "has", "had", "do", "did", "doing", "will", "can", "isn't", "aren't", "wasn't", "weren't", "to", "very", "would", "also", "after", "other", "whose", "upon", 
    "their", "could", "all", "none", "no", "us", "here", "eg", "how", "where", "such", "many", "more", "than", "highly", "annotation", "annotations", "along", "each", "both", "then", "any", "same", "only", "significant", "significantly", "without", "versus", "likely", "while", "later", "whether", "might", "particular", "among", "thus", "every", "through", "over", "thereby", "about", "they", "your", "them", "within", "should", "much", "because", "ie", "between", "aka", "either", "under", "fully", "most", "since", "using", "used", "if", "nor", "yet", "easily", "moreover", "despite", "does", "quite", "less", "her"]
  possiblewords.each do  |word|
    unless (generics.include?(word) or word.length < 3 or allwordsarray.include?(word + "s") )
        allwordshash << { :word => word, :frequency => allwordsarray.count(word)}
    end
  end
  return allwordshash.sort_by{|word| word[:frequency]}
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
