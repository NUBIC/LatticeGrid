require 'graphviz'
require 'stringio'

def graph_new(program, gopts={}, nopts={}, eopts={})
  # initialize new Graphviz graph
  # g = GraphViz::new( "G" )
  # program should be one of dot / neato / twopi / circo / fdp
  g = GraphViz::new( :G, :type => :graph, :use=>program)
  g[:overlap] = gopts[:overlap] || "orthoxy"
  g[:rankdir] = gopts[:rankdir] || "LR"
  
  # set global node options
  g.node[:color]    = nopts[:color]     || "#ddaa66"
  g.node[:style]    = nopts[:style]     || "filled"
  g.node[:shape]    = nopts[:shape]     || "box"
  g.node[:penwidth] = nopts[:penwidth]  || "1"
  g.node[:fontname] = nopts[:fontname]  || "Arial" # "Trebuchet MS"
  g.node[:fontsize] = nopts[:fontsize]  || "8"
  g.node[:fillcolor]= nopts[:fillcolor] || "#d8b090"
  g.node[:fontcolor]= nopts[:fontcolor] || "#775500"
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
                    :color => '#ffffff',
                    :fillcolor => '#ffffff',
                    :tooltip => 'Username is invalid')
  return g
end

def node_label (node_object)
  "#{node_object.name}: " +
  "Publications: #{node_object.total_pubs}; " + 
  "First author pubs: #{node_object.num_first_pubs}; " +
  "Last author pubs: #{node_object.num_last_pubs}; " +
  "intra-unit collab: #{node_object.num_intraunit_collaborators}; " +
  "inter-unit collabs: #{node_object.num_extraunit_collaborators}"
end

def update_node (node_object, opts)
  keys = %w{ URL target tooltip label fontcolor fillcolor color fontsize }
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
    aopts[:fontcolor] = aopts[:fontcolor] || "#502020"
    aopts[:fillcolor] = aopts[:fillcolor] || "#e8a820"
    aopts[:color]     = aopts[:color]     || "#904040"
    aopts[:fontsize]  = aopts[:fontsize]  || 9
  end
  update_node(add_root, aopts) 
end

def graph_newroot(graph, root, opts={} )
  opts[:fontcolor] = opts[:fontcolor] || "#444444"
  opts[:fontsize]  = opts[:fontsize]  || 10
  graph_addroot( graph, root, opts )
end

def graph_secondaryroot(graph, root, opts={})
  opts[:URL]       = opts[:URL]       || show_member_graphviz_url(root.username)
  opts[:fontcolor] = opts[:fontcolor] || "#502020"
  opts[:fillcolor] = opts[:fillcolor] || "#e8a820"
  opts[:color]     = opts[:color]     || "#904040"
  opts[:fontsize]  = opts[:fontsize]  || 10
  graph_addroot( graph, root, opts )
end

def graph_addleaf(graph, leaf, opts={} )
  add_leaf = graph.get_node( leaf.id.to_s )
  if add_leaf.nil? 
    opts[:URL]       = opts[:URL]       || show_member_graphviz_url(leaf.username)
    opts[:fontcolor] = opts[:fontcolor] || "#775500"
    opts[:fillcolor] = opts[:fillcolor] || "#d8b090"
    opts[:color]     = opts[:color]     || "#ddaa66"
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

def graph_add_node(program, g, root, connection, mesh_only=false, node_opts={}, edege_opts={} )
#    g.add_node(plant[0]).label = plant[1]+"\\n"+ plant[2]+", "+plant[3]+"\\n("+plant[0]+")"
  @graph_edges ||= {}
  return g if connection.nil?
  root_node = g.get_node( root.id.to_s )
  return g if root_node.nil?
  if ! @graph_edges.include?("#{root.id.to_s}_#{connection.colleague_id.to_s}") 
    leaf = connection.colleague
    leaf_node = g.get_node( leaf.id.to_s )
    nopts = node_opts.dup
    leaf_node = graph_addleaf(g, leaf, nopts) if leaf_node.nil?  # leaf_node = graph_addleaf(g, leaf, node_opts)
    @graph_edges << "#{root.id.to_s}_#{leaf.id.to_s}"
    @graph_edges << "#{leaf.id.to_s}_#{root.id.to_s}"
    tooltiptext = edge_label(connection, root, leaf)
    label = connection.publication_cnt
    weight = (mesh_only or connection.publication_cnt == 0) ? 3000/(connection.mesh_tags_ic+500) : connection.publication_cnt
    this_edge = graph_addedge(g, root_node, leaf_node, investigator_colleagues_copublication_url(connection.id), tooltiptext, label, weight )
  end
  return g
end

def graph_add_nodes(program, g, connections, mesh_only=false, node_opts={}, edege_opts={} )
#    g.add_node(plant[0]).label = plant[1]+"\\n"+ plant[2]+", "+plant[3]+"\\n("+plant[0]+")"
  @graph_edges ||= {}
  return g if connections.nil? or connections.length == 0
  root = connections[0].investigator
  root_node = g.get_node( root.id.to_s )
  return g if root_node.nil?
  connections.each do |connection|
    g = graph_add_node(program, g, root, connection, mesh_only=false, node_opts={}, edege_opts={} )
  end
  return g
end

def  trunc_and_join_array(array, count=20, delimiter=", ")
  if array.length > count.to_i
    array[0,count.to_i].join(delimiter)+'…'
  else
    array.join(delimiter)
  end
end


