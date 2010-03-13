module GraphvizHelper

  include TagsHelper
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
  
  def get_graph_path(file_path)
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
    if (mozilla_user_agent?) || internetexplorer_user_agent?
      get_object_method(file_name, content_type)
    else
      get_image_method(file_name, content_type)
    end
  end
  def get_image_method(file_name, content_type)
    '<p>image tag load from '+request.env["HTTP_USER_AGENT"]+'</p>
    <img src="'+image_path( file_name)+'" />'
  end
  def get_iframe_method(file_name, content_type)
    '<p>iframe tag load from '+request.env["HTTP_USER_AGENT"]+'</p>
    <iframe src="'+image_path( file_name)+'" />'
  end
  def get_object_method(file_name, content_type)
    '<!--[if IE]><embed src="'+image_path( file_name)+'" name="printable_map" type="'+content_type+'" /><![endif]-->
    <object data="'+file_name+'" type="'+content_type+' height="800px" width="1000px">
    	<a href="'+file_name+'">[<acronym>SVG</acronym> Image</a>] (Using the link to view the image requires a stand alone <acronym>SVG</acronym> viewer and your browser needs to be configured to use this player)
    </object>'
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

	def graphviz_remote_function(div_id, program_name,format_name, distance_name, stringency_name, id_name, analysis_name, include_orphans_name)
    remote_function( :update =>  {:success => div_id, :failure => 'flash_notice'},
            :before => "new Element.update('#{div_id}','<p>Loading graph ...</p>')",
            :complete => "new Effect.Highlight('#{div_id}');",
            :url => restless_graphviz_path(),
            :with => "'program='+encodeURIComponent( $('"+program_name.to_s+"').getValue())+'&format='+encodeURIComponent( $('"+format_name.to_s+"').getValue())+'&distance='+encodeURIComponent( $('"+distance_name.to_s+"').getValue())+'&stringency='+encodeURIComponent( $('"+stringency_name.to_s+"').getValue())+'&id='+encodeURIComponent( $('"+id_name.to_s+"').getValue())+'&analysis='+encodeURIComponent( $('"+analysis_name.to_s+"').getValue())+'&include_orphans='+encodeURIComponent( $('"+include_orphans_name.to_s+"').getValue())",
            :method => :get)
	end
	
	def handle_graphviz_params
     params[:program] ||= "neato"
     params[:analysis] ||= "member"
     params[:format] ||= "svg"
     params[:distance] ||= "2"
     params[:stringency] ||= "1"
     params[:include_orphans] ||= "1"
     params[:id] ||= "cam493"
     if params[:distance] != "1" and params[:program] == "dot"
       params[:program] = "neato"
     end
     if params[:include_orphans] != "1"
       params[:include_orphans] = "0"
     end
   end

   def build_graphviz_filepath
     # map to restful order
     # 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/:program.:format',
     "graphs/#{params[:id]}/#{params[:analysis]}/#{params[:distance]}/#{params[:stringency]}/#{params[:include_orphans]}/"
   end

   def build_graphviz_output_format
     output_format = params[:format]
     output_format = 'svg' if output_format == 'xml'
     output_format
   end
   
   def handle_graphviz_request        
     @output_format = build_graphviz_output_format()
     @graph_path = build_graphviz_filepath()
     mime_type = Mime::Type.lookup_by_extension(@output_format)
     @content_type = mime_type.to_s || "text/html"
   end

   def handle_graph_file
     graph_path = "public/#{@graph_path}"
     if ! graph_exists?( graph_path, params[:program], @output_format )
       graph = build_graph(params[:analysis],params[:program],params[:id], params[:distance], params[:stringency], params[:include_orphans])
       graph_output( graph, graph_path, params[:program], @output_format )
     end
   end

end