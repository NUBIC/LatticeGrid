# -*- ruby -*-

def GetConnections(abstract_id, investigator_id, number_years)
  start_date=number_years.years.ago
  piabstracts = InvestigatorAbstract.find(:all,
    :include => ["investigator","abstract"], 
    :conditions => ["abstract_id = :abstract_id AND abstracts.publication_date > :start_date AND NOT investigator_id = :investigator_id",
        {:abstract_id => abstract_id, :investigator_id => investigator_id, :start_date => start_date}])
   return piabstracts
end

def GetPIsInOrganization (unit_id)
  # load all investigators
  unit=OrganizationalUnit.find(unit_id)
  return (unit.primary_faculty+unit.associated_faculty).uniq
end

def InvestigatorBelongsToOrganization (unit_id, investigator)
  return true if investigator.home_department_id == unit_id
  investigator.investigator_appointments.each do |investigator_appointment|
    return true if investigator_appointment.organizational_unit_id == unit_id
  end
  return false
end

def AddToEdge(edge_hash, index1, index2)
  # will want to put each member in a different cloud dependent on program membership
  key1 = index2.to_s+' -- '+index1.to_s
  key2 = index1.to_s+' -- '+index2.to_s
  iterate_by=(key1 =~ /p/?1:0.5)  # if the key is for a program, add 1 as it is asymmetric. Add 0.5 for intraprogram keys as it is symmetric
  if edge_hash.has_key?(key1)
    edge_hash[key1] = edge_hash[key1]+iterate_by
  else
    edge_hash[key2] = edge_hash[key2]+iterate_by
  end
end


def SaveEdge(unit_id, investigator_id, member_on_abstract, edge_hash, retain_connections=false)
  # will want to put each member in a different cloud dependent on program membership
  if  InvestigatorBelongsToOrganization(unit_id, member_on_abstract.investigator)
    AddToEdge(edge_hash, investigator_id, member_on_abstract.investigator_id)
  elsif retain_connections
      AddToEdge(edge_hash, investigator_id, 'e'+member_on_abstract.investigator_id.to_s)
   else
     AddToEdge(edge_hash, investigator_id, 'p'+investigator.home_department_id.to_s)
    member_on_abstract.investigator.investigator_appointments.each do |investigator_appointment|
      AddToEdge(edge_hash, investigator_id, 'p'+investigator_appointment.organizational_unit_id.to_s)
    end
  end
end

def PrintEdges(edge_hash, print_internal=true, print_external=false, is_outside_subgraph=false)
  edge_hash.each  do |key, value| 
    value=value.to_i
    if value > 4
      if key =~ /e/ 
        puts "     #{key.sub(/e/,'')} [color=green,style=bold,label=#{value}]" if is_outside_subgraph
      elsif key =~ /p/ 
          puts "     #{key} [color=red,style=bold,label=#{value}]" if print_external
      else
        puts "     #{key} [style=bold,label=#{value}]" if print_internal
      end
    else
      if key =~ /e/ 
        puts "     #{key.sub(/e/,'')} [color=green,label=#{value}]" if is_outside_subgraph
      elsif key =~ /p/ 
        puts "     #{key} [color=red,label=#{value}]" if print_external
      else
        puts "     #{key} [label=#{value}]" if print_internal
      end
    end
  end
end  

def PrintHeader(this_program_num, num_years )
  puts "graph #{this_program_num} {"
  puts '   graph [rankdir=LR,nodesep=0.1]'
  puts '   compound=true; fontname="Arial"; fontsize=14; fontcolor=midnightblue; '
  puts '   label="FSM faculty, joint publications in the last '+num_years+' years"'
  puts '   node [fontname="Arial",fontsize=10]'
  puts '   edge [fontname="Arial",fontsize=10]'
end
