module GraphvizHelper
  require 'graphviz_config'
  include MeshHelper
  include ActionView::Helpers::AssetTagHelper #or whatever helpers you want

  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] &&
    request.env["HTTP_USER_AGENT" ][/(Mobile\/.+Safari)/]
  end

  def safari_user_agent?
    request.env["HTTP_USER_AGENT"] &&
    request.env["HTTP_USER_AGENT" ][/(AppleWebKit)/]
  end

  def opera_user_agent?
    request.env["HTTP_USER_AGENT"] &&
    request.env["HTTP_USER_AGENT" ][/(Opera)/]
  end

  def mozilla_user_agent?
    request.env["HTTP_USER_AGENT"] &&
    request.env["HTTP_USER_AGENT" ][/(Gecko)/]
  end

  def camino_user_agent?
    request.env["HTTP_USER_AGENT"] &&
    request.env["HTTP_USER_AGENT" ][/(Camino)/]
  end

  def internetexplorer_user_agent?
    request.env["HTTP_USER_AGENT"] &&
    request.env["HTTP_USER_AGENT" ][/(MSIE)/]
  end

  def get_graph_dir(file_path)
    image_path("../#{file_path}")
  end

  def get_pdf_method(file_name, content_type)
    if mozilla_user_agent? then
      get_iframe_method(file_name, content_type)
    else
      get_object_method(file_name, content_type)
    end
  end

  def get_svg_method(file_name, content_type)
    if (mozilla_user_agent?)
      get_object_method(file_name, content_type)
    elsif internetexplorer_user_agent?
      get_ie_svg_method(file_name, content_type)
    else
      get_image_method(file_name, content_type)
    end
  end

  def get_image_method(file_name, content_type)
    '<p>image tag load from '+request.env["HTTP_USER_AGENT"]+'</p>
    <img src="'+image_path( file_name)+'" />'.html_safe
  end

  def get_iframe_method(file_name, content_type)
    '<p>iframe tag load from '+request.env["HTTP_USER_AGENT"]+'</p>
    <iframe src="'+image_path( file_name)+'" />'.html_safe
  end

  def get_ie_svg_method(file_name, content_type)
     '<!--[if IE]><embed src="'+image_path( file_name)+'" name="printable_map" type="'+content_type+'" height="800px" width="990px" pluginspage="http://www.adobe.com/svg/viewer/install/" /><![endif]-->'.html_safe
  end

  def get_object_method(file_name, content_type)
    '<!--[if IE]><embed src="'+image_path( file_name)+'" name="printable_map" type="'+content_type+'" height="800px" width="990px"/><![endif]-->
    <object data="'+file_name+'" type="'+content_type+'" height="800px" width="990px">
    	<a href="'+file_name+'">[<acronym>SVG</acronym> Image</a>] (Using the link to view the image requires a stand alone <acronym>SVG</acronym> viewer and your browser needs to be configured to use this player)</a>
    </object>'.html_safe
  end

  def graph_method(format, file_name, content_type)
    if format =~ /svg|xml/ then
      get_svg_method(file_name, content_type)
    elsif format =~ /pdf/ then
      get_pdf_method(file_name, content_type)
    else
      get_image_method(file_name, content_type)
    end
  end

	def graphviz_remote_function(div_id, program_name,format_name, distance_name, stringency_name, id_name, analysis_name, include_orphans_name, start_date_name, end_date_name)
    remote_function( :update =>  {:success => div_id, :failure => 'flash_notice'},
            :before => "new Element.update('#{div_id}','<p>Loading graph ...</p>')",
            :complete => "new Effect.Highlight('#{div_id}');",
            :url => restless_graphviz_path(),
            :with => "'program='+encodeURIComponent( $('"+program_name.to_s+"').getValue())+'&format='+encodeURIComponent( $('"+format_name.to_s+"').getValue())+'&distance='+encodeURIComponent( $('"+distance_name.to_s+"').getValue())+'&stringency='+encodeURIComponent( $('"+stringency_name.to_s+"').getValue())+'&id='+encodeURIComponent( $('"+id_name.to_s+"').getValue())+'&analysis='+encodeURIComponent( $('"+analysis_name.to_s+"').getValue())+'&include_orphans='+encodeURIComponent( $('"+include_orphans_name.to_s+"').getValue())+'&start_date='+encodeURIComponent( $('"+start_date_name.to_s+"').getValue())+'&end_date='+encodeURIComponent( $('"+end_date_name.to_s+"').getValue())",
            :method => :get)
	end

  def build_graphviz_output_format
    output_format = params[:format]
    output_format = 'svg' if output_format == 'xml'
    output_format
  end

  def handle_graphviz_request
    @output_format = build_graphviz_output_format()
    @graph_path = build_graphviz_filepath(params)
    mime_type = Mime::Type.lookup_by_extension(@output_format)
    @content_type = mime_type.to_s || "text/html"
  end

  def handle_graph_file
    graph_dir = "public/#{@graph_path}"
    if ! graph_exists?( graph_dir, params[:program], @output_format )
      graph = build_graph(params[:analysis],params[:program],params[:id], params[:distance], params[:stringency], params[:include_orphans], params[:start_date], params[:end_date])
      graph_output( graph, graph_dir, params[:program], @output_format )
    end
  end

  def build_graph(analysis, program, id, distance, stringency, include_orphans, start_date, end_date)
    @graph_edges=[]
    #include_orphans = "0" if include_orphans.to_s != "1"
    graph = graph_new(program)

    graph = case analysis
            when "member"
              build_member_graph(graph, program, id, distance, stringency, include_orphans, start_date, end_date)
            when "member_mesh"
              build_member_mesh_graph(graph, program, id, distance, stringency, include_orphans)
            when "member_awards"
              build_member_awards_graph(graph, program, id, distance, stringency, include_orphans)
            when "mesh"
              build_mesh_graph(graph, program, id, distance, stringency, include_orphans)
            when "org"
              build_org_graph(graph, program, id, distance, stringency, include_orphans, start_date, end_date)
            when "org_org"
              build_org_org_graph(graph, program, id, distance, stringency, include_orphans)
            when "org_mesh"
              build_org_mesh_graph(graph, program, id, distance, stringency, include_orphans)
            else
              graph_no_data(graph, "Option #{analysis} was not found")
            end
    end
     graph
   end

  def build_member_graph(graph, program, id, distance, stringency, include_orphans, start_date, end_date)
    @investigator = Investigator.find_by_username(id)
    if @investigator.nil?
      graph = graph_no_data(graph, "Investigator id #{id} was not found")
    else
      graph_newroot(graph, @investigator)
      investigators = InvestigatorAbstract.investigator_shared_publication_count_by_date_range(@investigator.id, start_date, end_date)
      graph = graph_add_investigator_nodes(program, graph, @investigator, investigators, stringency)
      if distance != "1"
        opts = {}
        opts[:fillcolor] = LatticeGridHelper.second_degree_other_fill_color # super pale green
        investigators.each do |inv|
          coauths = InvestigatorAbstract.investigator_shared_publication_count_by_date_range(inv.id, start_date, end_date)
          graph = graph_add_investigator_nodes(program, graph, inv, coauths, stringency, false, opts)
        end
      end
    end
    graph
  end

  def build_member_mesh_graph(graph, program, id, distance, stringency, include_orphans)
    @investigator = Investigator.find_by_username(id)
    if @investigator.nil?
      graph = graph_no_data(graph, "Investigator id #{id} was not found")
    else
      graph_newroot(graph, @investigator)
      similar_investigators = @investigator.all_similar_investigators.mesh_ic(stringency)
      graph = graph_add_nodes(program, graph, similar_investigators, true)
      if distance == "2"
        opts = {}
        opts[:fillcolor] = LatticeGridHelper.second_degree_other_fill_color # super pale green
        similar_investigators.each do |similar|
          graph = graph_add_nodes(program, graph, similar.colleague.all_similar_investigators.mesh_ic(stringency), true, opts)
        end
      end
    end
    graph
  end

  def build_member_awards_graph(graph, program, id, distance, stringency, include_orphans)
    @investigator = Investigator.find_by_username(id)
    if @investigator.nil?
      graph = graph_no_data(graph, "Investigator id #{id} was not found")
    else
      graph_newroot(graph, @investigator)
      awards = @investigator.proposals
      graph = graph_add_award_nodes(program, graph, @investigator, awards)
      opts = {}
      opts[:fillcolor] = LatticeGridHelper.second_degree_other_fill_color # super pale green
      awards.each do |award|
        graph = graph_add_award_investigator_nodes(program, graph, award, award.investigators, false, opts)
      end
    end
    graph
  end

  def build_mesh_graph(graph, program, id, distance, stringency, include_orphans)
    mesh_terms = MeshHelper.do_mesh_search(id)
    mesh_names = mesh_terms.collect(&:name)
    colleagues = Investigator.find_tagged_with(mesh_names, :match_all => false)
    if colleagues.nil? or colleagues.length == 0
      return graph_no_data(graph, "No investigators with a primary tag (or tags) of #{mesh_names} were found")
    end
    filtered_colleagues = []
    colleagues.each do |colleague|
      filtered_colleagues << colleague if colleague.abstracts.find_tagged_with(mesh_names, :match_all => false).length.to_i >= stringency.to_i
    end
    if filtered_colleagues.length == 0
      return graph_no_data(graph, "No investigators had at least #{stringency} publications tagged with #{mesh_names}")
    else
      #first pass to add all primaries
      filtered_colleagues.each do |colleague|
        co_authors = colleague.co_authors.shared_pubs(1)
        if  distance == "0"
          co_authors = co_authors.collect{|ic| filtered_colleagues.include?(ic.colleague) ? ic : nil }.compact
        end
        if include_orphans == "1" or co_authors.length > 0
          graph_secondaryroot(graph, colleague)
          graph = graph_add_nodes(program, graph, co_authors) if co_authors.length > 0
        end
      end
      #now catch distance 2
      if distance == "2"
        filtered_colleagues.each do |colleague|
          co_authors = colleague.co_authors.shared_pubs(1)
          if distance == "0"
            co_authors = co_authors.collect{|ic| filtered_colleagues.include?(ic.colleague) ? ic : nil }.compact
          end
          if include_orphans == "1" or co_authors.length > 0
            graph_secondaryroot(graph, colleague)
            graph = graph_add_nodes(program, graph, co_authors) if co_authors.length > 0
            opts = {}
            opts[:fillcolor] = LatticeGridHelper.second_degree_other_fill_color # super pale green
            co_authors.each do |inner_colleague|
              inner_coauthors=inner_colleague.colleague.co_authors.shared_pubs(stringency)
              graph = graph_add_nodes(program, graph, inner_coauthors, false, opts)
            end
          end
        end
      end
    end
    graph
  end

  def build_org_graph(graph, program, id, distance, stringency, include_orphans, start_date, end_date)
    org_members = get_colleagues(id)
    #get_colleagues returns Investigator objects
    #slogger.info "org_members: #{org_members.length}"
    if org_members.nil?
      graph = graph_no_data(graph, "No colleagues found in #{org.name}")
    else
      #doing this twice so we don't miscolor the primaries
      org_members.each do |investigator|
        co_authors = InvestigatorAbstract.investigator_shared_publication_count_by_date_range(investigator.id, start_date, end_date)
        #array of Investigator objects returned with a shared_publication_count attribute for each Investigator
        #co_authors = investigator.co_authors.shared_pubs(stringency)
        if distance == "0" and ! co_authors.blank?
          co_authors = co_authors.collect{|ic| (org_members.include?(ic) and ic.shared_publication_count >= stringency.to_i) ? ic : nil }.compact
        elsif ! co_authors.blank?
          co_authors = co_authors.collect{|ic| (ic.shared_publication_count >= stringency.to_i) ? ic : nil }.compact
        end
        if include_orphans == "1" or ! co_authors.blank?
          graph_secondaryroot(graph, investigator)
          unless co_authors.blank?
            # these take an Investigator instead of a InvestigatorColleague
            graph = graph_add_investigator_nodes(program, graph, investigator, co_authors, stringency)
          end
        end
      end
      # now adding the secondaries, if any
      if distance == "2"
        org_members.each do |investigator|
          co_authors = InvestigatorAbstract.investigator_shared_publication_count_by_date_range(investigator.id, start_date, end_date)
          #array of Investigator objects returned with a shared_publication_count attribute for each Investigator
          #co_authors = investigator.co_authors.shared_pubs(stringency)
          if ! co_authors.blank?
            co_authors = co_authors.collect{|ic| (ic.shared_publication_count >= stringency.to_i) ? ic : nil }.compact
          end
          unless co_authors.blank?
            graph_secondaryroot(graph, investigator)
            graph = graph_add_investigator_nodes(program, graph, investigator, co_authors, stringency) unless co_authors.blank?
            opts = {}
            opts[:fillcolor] = LatticeGridHelper.second_degree_other_fill_color # super pale green
            co_authors.each do |inv|
              inner_coauthors = InvestigatorAbstract.investigator_shared_publication_count_by_date_range(inv.id, start_date, end_date)
              graph = graph_add_investigator_nodes(program, graph, inv, inner_coauthors, stringency, false, opts)
            end
          end
        end
      end
    end
    graph
  end

  def build_org_org_graph(graph, program, id, distance, stringency, include_orphans)
    orgs = get_orgs(id)
    all_orgs = OrganizationalUnit.all - orgs
    #slogger.info "colleagues: #{colleagues.length}"
    if orgs.nil?
      graph = graph_no_data(graph, "No orgs found")
    else
      orgs.each do |org|
        all_orgs.each do |intersecting_org|
          shared_pubs = org.abstracts_shared_with_org(intersecting_org)
          if shared_pubs.length >= stringency.to_i
            graph_secondaryroot(graph, org, {:URL=>show_org_graphviz_url(org.id), :tooltip=>"Total publications: #{org.organization_abstracts.length}; Faculty: #{org.all_faculty.length}, Members: #{org.all_members.length}" })
            graph = graph_add_org_node(program, graph, org, intersecting_org, shared_pubs, false, {:URL=>show_org_org_graphviz_url(intersecting_org.id), :tooltip=>"Total publications: #{intersecting_org.organization_abstracts.length}; Faculty: #{intersecting_org.all_faculty.length}, Members: #{intersecting_org.all_members.length}"}) if shared_pubs.length > 0
          end
        end
      end
    end
    graph
  end

  def build_org_mesh_graph(graph, program, id, distance, stringency, include_orphans)
    colleagues = get_colleagues(id)
    if colleagues.nil?
      graph = graph_no_data(graph, "No colleagues found in #{org.name}")
    else
      # do two passes to color nodes properly
      colleagues.each do |colleague|
        similar_investigators = colleague.all_similar_investigators.mesh_ic(stringency)
        if distance == "0"
          similar_investigators = similar_investigators.collect{|ic| colleagues.include?(ic.colleague) ? ic : nil }.compact
        end
        if include_orphans == "1" or similar_investigators.length > 0
          graph_secondaryroot(graph, colleague)
          graph = graph_add_nodes(program, graph, similar_investigators, true) if similar_investigators.length > 0
        end
      end
      # second pass if the distance is two
      if distance == "2"
        colleagues.each do |colleague|
          similar_investigators = colleague.all_similar_investigators.mesh_ic(stringency)
          if distance == "0"
            similar_investigators = similar_investigators.collect{|ic| colleagues.include?(ic.colleague) ? ic : nil }.compact
          end
          if include_orphans == "1" or similar_investigators.length > 0
            graph_secondaryroot(graph, colleague)
            graph = graph_add_nodes(program, graph, similar_investigators, true) if similar_investigators.length > 0
            opts = {}
            opts[:fillcolor] = LatticeGridHelper.second_degree_other_fill_color # super pale green
            similar_investigators.each do |similar|
              inner_similar_investigators = similar.colleague.all_similar_investigators.mesh_ic(stringency)
              graph = graph_add_nodes(program, graph, inner_similar_investigators, true, opts)
            end
          end
        end
      end
    end
    graph
  end

end
