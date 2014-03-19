@all_edges = Hash.new(0)
@all_programs = nil
@years_to_visualize = 5
@cluster_style = ["color=lightgrey; style=filled; node [style=filled]; ",
  "color=lightsteelblue; style=filled; node [style=filled]; ",
  "color=whitesmoke; style=filled; node [style=filled]; "]

require 'visualization_utilities'

task :getPrograms => :environment do
  @all_programs = Program.include([:investigators])
                         .order('programs.program_number, investigators.last_name')
                         .to_a
end

task :getConnectors => :getPrograms do
  # load all investigatorContacts
  # please pass in a program_id such as 'rake getConnectors program_num=2'
  if ENV['program_num'].blank? then
    this_program_num = 1
  else
    this_program_num = ENV['program_num']
  end
  if ENV['print_internal'].blank? then
    print_internal = false
  else
    print_internal = ENV['print_internal']
  end
  if ENV['print_external'].blank? then
    print_external = false
  else
    print_external = ENV['print_external']
  end
  if ENV['retain_connections'].blank? then
    retain_connections = false
  else
    retain_connections = ENV['print_external']
  end
  PrintHeader(this_program_num, @years_to_visualize.to_s )
  @all_programs.each do |program|
    if program.program_number.to_i <= this_program_num.to_i
      puts ' subgraph cluster_' + program.program_number.to_s + ' {'
      puts '  ' + @cluster_style[program.program_number % 3] + ' label="' + program.program_title + '";'
      program.investigators.each do |investigator|
        pubsTotal = 0
        pubsWithConnections = 0
        connectedInvestigators = 0
        puts '    ' + investigator.id.to_s + ' [label="' + investigator.first_name + ' ' + investigator.last_name + '\n' + investigator.investigator_abstracts.length.to_s + ' pubs"]'
        investigator.investigator_abstracts.each do |investigator_abstract|
          connections=GetConnections(investigator_abstract.abstract_id, investigator.id, @years_to_visualize)
          connectedInvestigators=connectedInvestigators+connections.length
          pubsWithConnections=pubsWithConnections+1 if connections.length > 0
          connections.each do |member_on_abstract|
            SaveEdge(program.id, investigator.id, member_on_abstract, @all_edges, retain_connections)
          end
        end
      end
      # PrintEdges(@all_edges, true, false)
      PrintEdges(@all_edges, print_internal, print_external)
      puts '}'
      # break
    else
      puts ' p' + program.program_number.to_s + ' [shape=plaintext,style=filled,color=olivedrab,label="'+program.program_title+'"];' if print_external
    end
  end
  PrintEdges(@all_edges, false, false, retain_connections) if retain_connections
  puts '}'
end

