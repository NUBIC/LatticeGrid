module InvestigatorsHelper
#  require 'ldap_utilities' #specific ldap methods
  require 'config' #heading configuration options
  
  def handle_member_name(merge_ldap=true)
    return if params[:id].blank?
    if !params[:format].blank? and (params[:format] !~ /json|xml|pdf|xls|doc/) then #reassemble the username
      params[:id]=params[:id]+"."+params[:format]
    end
    if params[:name].blank? then
      if params[:id] =~ /^[0-9]+$/
        @investigator = Investigator.include_deleted(params[:id])
      else
        @investigator = Investigator.find_by_username_including_deleted(params[:id])
      end
      if @investigator
        params[:investigator_id] = @investigator.id
        params[:name] =  @investigator.first_name + " " + @investigator.last_name
        merge_investigator_db_and_ldap(@investigator) if ( LatticeGridHelper.ldap_perform_search? and merge_ldap)
      else
        params[:investigator_id]=0
        logger.error("Attempt to access invalid username (netid) #{params[:id]}") 
        flash[:notice] = "Sorry - invalid username <i>#{params[:id]}</i>"
        params.delete(:id)
      end
    end
  end
  
  def merge_investigator_db_and_ldap(investigator)
    return investigator if investigator.blank? or investigator.username.blank?
    begin
      pi_data = GetLDAPentry(investigator.username)
      if pi_data.nil?
        if defined?(logger) and ! logger.error.blank?
          logger.warn("Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null for #{params[:name]} using netid #{investigator.username}.")
        else
          puts "Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null for #{params[:name]} using netid #{investigator.username}."
        end
      elsif pi_data.blank?
        if defined?(logger) and ! logger.error.blank?
          logger.warn("Entry not found. GetLDAPentry returned null using netid #{investigator.username}.")
        else
          puts "Entry not found. GetLDAPentry returned null using netid #{investigator.username}."
        end
      else
        ldap_rec=CleanPIfromLDAP(pi_data)
        investigator = BuildPIobject(ldap_rec) if investigator.id.blank?
        investigator = MergePIrecords(investigator,ldap_rec)
      end
    rescue Exception => error
      if defined?(logger) and ! logger.error.blank?
        logger.error("Probable error reaching the LDAP server in GetLDAPentry: #{error.message}")
      else
        puts "Probable error reaching the LDAP server in GetLDAPentry: #{error.message}"
      end
    end
  end
  
  def nav_heading()
    out="<span id='nav_links'>"
    if not (controller.action_name == 'show' and controller.controller_name == 'investigators')
      out+= link_to('Publications', show_investigator_url(:id=>params[:id], :page=>1) ) 
      out+= " &nbsp;  &nbsp; " 
    end
    out+= " Publication Graphs: " 
    if not (controller.action_name == 'show_member' and controller.controller_name == 'graphs')
      out+= link_to('Flash', show_member_graph_url(params[:id]) ) 
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show_member' and controller.controller_name == 'graphviz')
      out+= link_to( "Graphviz", show_member_graphviz_url(params[:id]) )
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'investigator_wheel' and controller.controller_name == 'graphviz')
      out+= link_to( "Wheel", investigator_wheel_graphviz_url(params[:id]) )
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show' and controller.controller_name == 'cytoscape')
      out+= link_to( "Cytoscape", cytoscape_url(params[:id]))
      out+= " &nbsp;  &nbsp; "  
    end
    out+"</span>"
  end

  def nav_heading2()
    out="<span id='nav_links2'>"
    if defined?(LatticeGridHelper.include_awards?) and LatticeGridHelper.include_awards?() then
      out+= " Award data: " 
      if not (controller.action_name == 'awards' and controller.controller_name == 'cytoscape')
        out+= link_to('Graph', awards_cytoscape_url(params[:id]) ) 
        out+= " &nbsp;  &nbsp; " 
      end
      if not (controller.action_name == 'investigator' and controller.controller_name == 'awards')
        out+= link_to( "Report", investigator_award_url(params[:id]) )
        out+= " &nbsp;  &nbsp; " 
      end
    end
    out+= " MeSH: " 
    if not (controller.action_name == 'show_member_mesh' and controller.controller_name == 'graphviz')
      out+= link_to( "similarities graph", show_member_mesh_graphviz_url(params[:id]))
      out+= " &nbsp;  &nbsp; "  
    end
    out+"</span>"
  end

  def nav_heading3()
     out="<span id='nav_links3'>"
     if defined?(LatticeGridHelper.include_studies?) and LatticeGridHelper.include_studies?() then
       out+= " Study data: &nbsp; " 
       if not (controller.action_name == 'studies' and controller.controller_name == 'cytoscape')
         out+= link_to('Graph', studies_cytoscape_url(params[:id]) ) 
         out+= " &nbsp;  &nbsp; " 
       end
       if not (controller.action_name == 'investigator' and controller.controller_name == 'studies')
         out+= link_to( "Report", investigator_study_url(params[:id]) )
         out+= " &nbsp;  &nbsp; " 
       end
       if not (controller.action_name == 'show_all' and controller.controller_name == 'cytoscape')
         out+= " &nbsp;  Combined data: &nbsp; " 
         out+= link_to( "Graph", show_all_cytoscape_url(params[:id]) )
         out+= " &nbsp;  &nbsp; " 
       end
     end
     out+"</span>"
   end

  def investigator_bio_heading(investigator, all_abstracts=nil, title=nil)
    out="<table class='borderless' width='100%'><tr><td style='vertical-align: top'>"
    if defined?(investigator) and ! investigator.blank?
      out+="<span id='full_name'>"
      out+=investigator.full_name
      out+="</span>"
    end
    if defined?(title) and ! title.blank?
      out+="<br/><span id='page_title'>"
      out+=title
      out+="</span>"
    end
    out+=" &nbsp; </td><td>"
    profile_link = edit_profile_link()
    unless profile_link.blank?
      out+= profile_link
      out+= " &nbsp;  &nbsp; "
    end
    if defined?(all_abstracts) and ! all_abstracts.nil? and all_abstracts.length > 10
      publications_per_year=abstracts_per_year_as_string(all_abstracts)
      out+= "<span class='inlinebarchart' values='#{publications_per_year}' title='publications per year: #{publications_per_year}'>&nbsp;</span>"
      out+= sparkline_barchart_setup()
    end
    out+= "<br/>"
    out+=nav_heading()
    out+= "<br/>"
    out+= nav_heading2()
    out+= "<br/>"
    out+= nav_heading3()
    out+= "</td></tr></table>"
    
    out
  end
  
end
