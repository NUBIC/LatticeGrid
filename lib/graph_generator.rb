require 'graphviz'
require 'stringio'

# gold: #FFAD33
# existing gold (browner): #e8a820
# pale gold: #ddaa66
# rose pale gold:  #d8b090
# official NU purple (dark!)  #3d0d4c
# light NU purple  #A28BA9
# pale NU purple #E6E0E8
# pale green #CCF5CC
# rose brown for outline: #904040
# pale, pale blue:  E0ECF8

#text colors
# bright gold:  #FFAD33
# dark gold: #CC7A00
# dark gray green:  #474724
# medium green:  #478D31
# lighter brown:  #775500
# light rose: #904040
# dark rose brown:  #663300
# dark red brown: #502020
# medium gray:  #6A6A87
# dark NU purple:  #370C44
# dark blue:  #333385

# sets of color
# roots

# connected nodes:
#font text - dark purple:   #47008F
#fill - pale NU purple:  #E6E0E8
#line - NU purple:  #3d0d4c"

# 2nd level nodes:
#font text - dark purple:   #47008F
#fill - pale green #CCF5CC
#line - NU purple:  #3d0d4c"


def graph_new(program, gopts={}, nopts={}, eopts={})
  # initialize new Graphviz graph
  # g = GraphViz::new( "G" )
  # program should be one of dot / neato / twopi / circo / fdp
  g = GraphViz::new( :G, :type => :graph, :use=>program)
  g[:overlap] = gopts[:overlap] || "orthoxy"
  g[:rankdir] = gopts[:rankdir] || "LR"
  
  # set global node options
  g.node[:color]    = nopts[:color]     || "#3d0d4c"
  g.node[:style]    = nopts[:style]     || "filled"
  g.node[:shape]    = nopts[:shape]     || "box"
  g.node[:penwidth] = nopts[:penwidth]  || "1"
  g.node[:fontname] = nopts[:fontname]  || "Arial" # "Trebuchet MS"
  g.node[:fontsize] = nopts[:fontsize]  || "8"
  g.node[:fillcolor]= nopts[:fillcolor] || LatticeGridHelper.default_fill_color
  g.node[:fontcolor]= nopts[:fontcolor] || "#474724"
  g.node[:margin]   = nopts[:margin]    || "0.0"
  g.node[:width]    = nopts[:width]     || "0.2"
  g.node[:height]   = nopts[:height]    || "0.1"
  g.node[:shape]    = nopts[:shape]     ||  "ellipse"
  g.node[:margin]   = nopts[:margin]    || "0.05"
  
  # set global edge options
  g.edge[:color]     = eopts[:color]     || "#999999"
  g.edge[:len]       = eopts[:len]       || "1"
  g.edge[:fontsize]  = eopts[:fontsize]  || "6"
  g.edge[:fontcolor] = eopts[:fontcolor] || "#444444"
  g.edge[:fontname]  = eopts[:fontname]  || "Verdana"
  g.edge[:dir]       = eopts[:dir]       || "forward"
  g.edge[:arrowsize] = eopts[:arrowsize] || "0.0"
  
  return g
end

def graph_output( g, path, file_name, output_format )
  output_format = 'svg' if output_format == 'xml'
  file_name = clean_filename(file_name)
#  logger.info "graph_output( #{g}, #{path}, #{file_name}, #{output_format} )"
  graph_output_format = path+file_name+"."+output_format
  check_path(path)
  begin
    Dir.entries(path)
    g.output( output_format => graph_output_format )
  rescue Exception => error
    logger.error("graph_output error: #{error.message}")
    logger.error("path is #{path}; filename is #{file_name}, outputformat is #{output_format}.")
    puts "unable to link to directory #{path} or write out file"
  end

end

def clean_filename(filename)
  filename.downcase.gsub(/[^a-z0-9]+/,'_')
end

def check_path(path)
  begin
    Dir.entries(path)
  rescue
    dir=""
    begin
      path.split("/").each do |dir_name|
        dir += dir_name+"/"
        add_path(dir)
      end
    rescue Exception => error
      logger.error("check_path error: #{error.message}")
      puts "unable to create directory #{path}. Made it to #{dir}"
    end
  end
end

def add_path(path)
  begin
    Dir.entries(path)
  rescue
    Dir.mkdir(path)
  end
end

def graph_exists?( path, file_name, output_format )
  complete_name = path+file_name+"."+output_format
  return File.exist?( complete_name )
end

def graph_no_data (g, message)
  main        = g.add_node( "main", 
                    :label=> message, 
                    :URL => abstracts_url(), 
                    :target=>'_top', 
                    :shape => 'box',
                    :color => LatticeGridHelper.white_fill_color,
                    :fillcolor => LatticeGridHelper.white_fill_color,
                    :tooltip => 'Username is invalid')
  return g
end

def node_label (node_object)
  "#{node_object.name}: " +
  "Publications: #{node_object.total_publications}; " + 
  "First author pubs: #{node_object.num_first_pubs}; " +
  "Last author pubs: #{node_object.num_last_pubs}; " +
  "intra-unit collab: #{node_object.num_intraunit_collaborators}; " +
  "inter-unit collabs: #{node_object.num_extraunit_collaborators}"
end

def node_award_label (node_object)
  "#{node_object.title}: " +
  "Amount: #{node_object.total_amount}; " + 
  "Sponsor: #{node_object.sponsor_name}; " +
  "Sponsor type: #{node_object.sponsor_type_name}; " +
  (node_object.investigator_proposals.blank? ? " " : "Collaborators: #{node_object.investigator_proposals.length}; " )
end

def update_node (node_object, opts)
  keys = %w{ URL target tooltip label fontcolor fillcolor color fontsize shape }
  opts.keys.each do |key|
    if !opts[key].blank?
      node_object[key] = opts[key]
    end
  end
  node_object
end

def graph_addroot(graph, root, aopts={} )
  add_root = graph.get_node( root.id.to_s )
  if add_root.nil? 
    add_root = graph.add_node( root.id.to_s)
    aopts[:URL]       = aopts[:URL]       || show_investigator_url(root.username, 1)
    aopts[:target]    = aopts[:target]    || "_top"
    aopts[:tooltip]   = aopts[:tooltip]   || node_label(root)
    aopts[:label]     = aopts[:label]     || root.name
    aopts[:fontcolor] = aopts[:fontcolor] || "#3d0d4c"
    aopts[:fillcolor] = aopts[:fillcolor] || LatticeGridHelper.root_fill_color
    aopts[:color]     = aopts[:color]     || "#904040"
    aopts[:fontsize]  = aopts[:fontsize]  || 9
  end
  update_node(add_root, aopts) 
end

def graph_newroot(graph, root, opts={} )
  opts[:fontcolor] = opts[:fontcolor] || "#333385"
  opts[:fontsize]  = opts[:fontsize]  || 10
  graph_addroot( graph, root, opts )
end

def graph_secondaryroot(graph, root, opts={})
  opts[:URL]       = opts[:URL]       || show_member_graphviz_url(root.username)
  opts[:fontcolor] = opts[:fontcolor] || "#663300"
  opts[:fillcolor] = opts[:fillcolor] || LatticeGridHelper.root_other_fill_color
  opts[:color]     = opts[:color]     || "#904040"
  opts[:fontsize]  = opts[:fontsize]  || 10
  graph_addroot( graph, root, opts )
end

def graph_addleaf(graph, leaf, opts={} )
  add_leaf = graph.get_node( leaf.id.to_s )
  if add_leaf.nil? 
    opts[:URL]       = opts[:URL]       || show_member_graphviz_url(leaf.username)
    opts[:fontcolor] = opts[:fontcolor] || "#47008F"
    opts[:fillcolor] = opts[:fillcolor] || LatticeGridHelper.first_degree_other_fill_color
    opts[:color]     = opts[:color]     || "#3d0d4c"
    opts[:fontsize]  = opts[:fontsize]  || 9
    graph_addroot( graph, leaf, opts )
  end
end

def graph_addawardleaf(graph, leaf, opts={} )
  add_leaf = graph.get_node( leaf.id.to_s )
  if add_leaf.nil? 
    opts[:URL]       = opts[:URL]       || ""
    opts[:label]     = opts[:label]     || leaf.title
    opts[:tooltip]   = opts[:tooltip]   || node_award_label(leaf)
    opts[:fontcolor] = opts[:fontcolor] || "#47008F"
    opts[:fillcolor] = opts[:fillcolor] || LatticeGridHelper.first_degree_other_fill_color
    opts[:color]     = opts[:color]     || "#3d0d4c"
    opts[:fontsize]  = opts[:fontsize]  || 9
    graph_addroot( graph, leaf, opts )
  end
end

def graph_addedge(graph, parent, child, url, tooltip, label, weight )
  gedge = graph.add_edge( parent, child,
              :edgeURL => "#{url}", 
              :edgetarget=>'_top', 
              :edgetooltip => tooltip, 
              :minlen => '0.15',
              :label => "#{label}", 
              :labelURL => url, 
              :labeltarget=>'_top', 
              :labeltooltip => tooltip, 
              :weight => "#{weight}"  )
end

def edge_label(connection, root, leaf)
  "#{connection.publication_cnt} shared publications between #{leaf.name} and #{root.name}; " + 
  "MeSH similarity score: #{connection.mesh_tags_ic.round}; " + 
  "tags: "+ trunc_and_join_array((root.tag_list & leaf.tag_list))
end

def edge_award_label(leaf)
  "#{leaf.total_amount} dollars"
end

def org_edge_label(root, leaf, shared_pubs)
  "#{shared_pubs.length} shared publications between #{leaf.name} and #{root.name}; " 
end

def graph_add_org_node(program, g, root, leaf, shared_pubs, mesh_only=false, node_opts={}, edege_opts={} )
#    g.add_node(plant[0]).label = plant[1]+"\\n"+ plant[2]+", "+plant[3]+"\\n("+plant[0]+")"
  @graph_edges ||= {}
  return g if leaf.nil?
  root_node = g.get_node( root.id.to_s )
  return g if root_node.nil?
  if ! @graph_edges.include?("#{root.id.to_s}_#{leaf.id.to_s}") 
    leaf_node = g.get_node( leaf.id.to_s )
    nopts = node_opts.dup
    leaf_node = graph_addleaf(g, leaf, nopts) if leaf_node.nil?  # leaf_node = graph_addleaf(g, leaf, node_opts)
    @graph_edges << "#{root.id.to_s}_#{leaf.id.to_s}"
    @graph_edges << "#{leaf.id.to_s}_#{root.id.to_s}"
    tooltiptext = org_edge_label(root, leaf, shared_pubs)
    label = shared_pubs.length.to_s
    weight = shared_pubs.length.to_s
    this_edge = graph_addedge(g, root_node, leaf_node, show_org_org_graphviz_url(leaf.id), tooltiptext, label, weight )
  end
  return g
end

def graph_add_node(program, g, root, root_node, connection, unit_list=[], mesh_only=false, node_opts={}, edege_opts={} )
#    g.add_node(plant[0]).label = plant[1]+"\\n"+ plant[2]+", "+plant[3]+"\\n("+plant[0]+")"
  @graph_edges ||= {}
  return g if connection.nil?
  return g if root.id == connection.colleague_id
  if ! @graph_edges.include?("#{root.id.to_s}_#{connection.colleague_id.to_s}") 
    leaf = connection.colleague
    leaf_node = g.get_node( leaf.id.to_s )
    if leaf_node.nil? then # leaf_node = graph_addleaf(g, leaf, node_opts) 
      nopts = node_opts.dup
      intersection_unit_list = (unit_list & leaf.unit_list).compact
      if intersection_unit_list.length == 0
        nopts[:shape] = "doubleoctagon" 
        if nopts[:fillcolor].blank? # first degree other
          nopts[:fillcolor] = LatticeGridHelper.first_degree_other_fill_color
        else #second degree member
          nopts[:fillcolor] = LatticeGridHelper.second_degree_other_fill_color
        end
      else
        if nopts[:fillcolor].blank? # first degree member
          nopts[:fillcolor] = LatticeGridHelper.first_degree_fill_color
        else #second degree member
          nopts[:fillcolor] = LatticeGridHelper.second_degree_fill_color
        end
      end
      leaf_node = graph_addleaf(g, leaf, nopts) 
    end
    @graph_edges << "#{root.id.to_s}_#{leaf.id.to_s}"
    @graph_edges << "#{leaf.id.to_s}_#{root.id.to_s}"
    tooltiptext = edge_label(connection, root, leaf)
    label = connection.publication_cnt
    weight = (mesh_only or connection.publication_cnt == 0) ? 3000/(connection.mesh_tags_ic+500) : connection.publication_cnt
    this_edge = graph_addedge(g, root_node, leaf_node, investigator_colleagues_copublication_url(connection.id), tooltiptext, label, weight )
  end
  return g
end

def graph_add_nodes(program, g, connections, mesh_only=false, node_opts={}, edge_opts={} )
#    g.add_node(plant[0]).label = plant[1]+"\\n"+ plant[2]+", "+plant[3]+"\\n("+plant[0]+")"
  @graph_edges ||= {}
  return g if connections.nil? or connections.length == 0
  root = connections[0].investigator
  return g if root.nil?
  root_node = g.get_node( root.id.to_s )
  return g if root_node.nil?
  unit_list = root.unit_list
  connections.each do |connection|
    g = graph_add_node(program, g, root, root_node, connection, unit_list, mesh_only=false, node_opts, edge_opts )
  end
  return g
end

def graph_add_award_nodes(program, g, root, awards, mesh_only=false, node_opts={}, edge_opts={} )
#    g.add_node(plant[0]).label = plant[1]+"\\n"+ plant[2]+", "+plant[3]+"\\n("+plant[0]+")"
  @graph_edges ||= {}
  return g if awards.nil? or awards.length == 0
  root_node = g.get_node( root.id.to_s )
  return g if root_node.nil?
  awards.each do |award|
    g = graph_add_award_node(program, g, root, root_node, award, mesh_only=false, node_opts, edge_opts )
  end
  return g
end

def graph_add_award_node(program, g, root, root_node, award, mesh_only=false, node_opts={}, edege_opts={} )
#    g.add_node(plant[0]).label = plant[1]+"\\n"+ plant[2]+", "+plant[3]+"\\n("+plant[0]+")"
  @graph_edges ||= {}
  return g if award.nil?
  if ! @graph_edges.include?("#{root.id.to_s}_#{award.id.to_s}") 
    award_node = g.get_node( award.id.to_s )
    if award_node.nil? then  
      nopts = node_opts.dup
      award_node = graph_addawardleaf(g, award, nopts) 
    end
    @graph_edges << "#{root.id.to_s}_#{award.id.to_s}"
    @graph_edges << "#{award.id.to_s}_#{root.id.to_s}"
    tooltiptext = ""
    tooltiptext = edge_award_label(award)
    label = award.total_amount
    weight = label
    this_edge = graph_addedge(g, root_node, award_node, investigator_colleagues_copublication_url(award.id), tooltiptext, label, weight )
  end
  return g
end

def graph_add_investigator_node(program, g, root, root_node, investigator, mesh_only=false, node_opts={}, edege_opts={} )
#    g.add_node(plant[0]).label = plant[1]+"\\n"+ plant[2]+", "+plant[3]+"\\n("+plant[0]+")"
  @graph_edges ||= {}
  return g if investigator.nil?
  if ! @graph_edges.include?("#{root.id.to_s}_#{investigator.id.to_s}") 
    leaf_node = g.get_node( investigator.id.to_s )
    if leaf_node.nil? then # leaf_node = graph_addleaf(g, leaf, node_opts) 
      nopts = node_opts.dup
      leaf_node = graph_addleaf(g, investigator, nopts) 
    end
    @graph_edges << "#{root.id.to_s}_#{investigator.id.to_s}"
    @graph_edges << "#{investigator.id.to_s}_#{root.id.to_s}"
    tooltiptext = "amount: #{root.total_amount}"
    label = "amount: #{root.total_amount}"
    weight = label
    this_edge = graph_addedge(g, root_node, leaf_node, investigator_colleagues_copublication_url(investigator.id), tooltiptext, label, weight )
  end
  return g
end

def graph_add_investigator_nodes(program, g, root, investigators, mesh_only=false, node_opts={}, edge_opts={} )
#    g.add_node(plant[0]).label = plant[1]+"\\n"+ plant[2]+", "+plant[3]+"\\n("+plant[0]+")"
  @graph_edges ||= {}
  return g if investigators.nil? or investigators.length == 0
  return g if root.nil?
  root_node = g.get_node( root.id.to_s )
  return g if root_node.nil?
  investigators.each do |investigator|
    g = graph_add_investigator_node(program, g, root, root_node, investigator, mesh_only=false, node_opts, edge_opts )
  end
  return g
end


def  trunc_and_join_array(array, count=20, delimiter=", ", break_on=50, break_delimiter="<br>&nbsp; &nbsp; &nbsp; ")
  return "" if array.blank?
  new_array = array[0..break_on-1]
  if array.length > break_on.to_i
    array[break_on..-1].each_slice(break_on) { |a| new_array << break_delimiter+a[0]; new_array << a[1..-1] }
  end
  if array.length > count.to_i
    new_array.flatten[0,count.to_i].join(delimiter)+'…'
  else
    new_array.flatten.join(delimiter)
  end
end
