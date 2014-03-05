module InvestigatorsHelper
  # require 'ldap_utilities' # specific ldap methods
  require 'config' # heading configuration options

  def search_options
    [
      ['Investigator', 'Investigator'],
      ['All By Investigator', 'AllByInvestigator'],
      ['Title Or Abstract', 'TitleOrAbstract'],
      ['Journal', 'Journal'],
      ['Faculty Summary', 'FacultySummary'],
      ['Keywords', 'Keywords'],
      ['MeSH', 'MeSH'],
      ['All', 'All']
    ]
  end

  def handle_member_name(merge_ldap=true)
    return if params[:id].blank?
    if !params[:format].blank? and (params[:format] !~ /js|json|xml|pdf|xls|doc/) then #reassemble the username
      params[:id]=params[:id]+"."+params[:format]
    end
    if @investigator.blank? then
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

  def handle_investigator_delete(investigator, do_delete=false)
    if do_delete == "1" or do_delete == true
      deleted_on = investigator.deleted_at || investigator.end_date || Time.now
      investigator.end_date = deleted_on if investigator.end_date.blank?
      investigator.deleted_at = deleted_on if investigator.deleted_at.blank?
      investigator.deleted_ip ||= request.remote_ip if defined?(request) and ! request.nil?
      investigator.deleted_id ||= session[:user_id] if defined?(session) and ! session.nil? and ! session[:user_id].blank?
    else
      investigator.end_date = nil
      investigator.deleted_at = nil
      investigator.deleted_ip = nil
      investigator.deleted_id = nil
    end
  end

  def handle_investigator_investigator_apppointments_update(nparams, appointment_type='Member')
    logger.error "in handle_investigator_investigator_apppointments_update"
    return if nparams[:investigator].blank?
    logger.error 'params did not have an investigator_appointment! ' if nparams[:investigator]['investigator_appointments'].blank?
    ias = nparams[:investigator][:investigator_appointments]
    ids = nparams[:investigator][:investigator_appointments][:organizational_unit_id]
    logger.error "investigator_appointments_org_unit_ids = #{ids.inspect}, ias = #{ias.inspect}"
    nparams[:investigator].delete(:investigator_appointments)
    nparams[:investigator][:investigator_appointments] = []
    ids.each do |id|
      nparams[:investigator][:investigator_appointments] << {:organizational_unit_id => id, :type => appointment_type, :investigator_id =>nparams[:investigator_id] }
    end
    return params
  end

  def get_member_type(investigator)
    return 'Member' if investigator.only_member_appointments.length > 0
    return 'AssociateMember' if investigator.associate_member_appointments.length > 0
    return 'Member'
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
    out+= "Visualizations: "
    if not (controller.action_name == 'show_member' and controller.controller_name == 'graphs')
      out+= link_to('Radial1', show_member_graph_url(params[:id]) )
    else
      out+= "<span class='disabled'>Radial1</span>"
    end
    out+= " &nbsp;  &nbsp; "
    if not (controller.action_name == 'show' and controller.controller_name == 'cytoscape')
      out+= link_to( "Radial2", cytoscape_url(params[:id]))
    else
      out+= "<span class='disabled'>Radial2</span>"
    end
    out+= " &nbsp;  &nbsp; "
    if not (controller.action_name == 'show_member' and controller.controller_name == 'graphviz')
      out+= link_to( "Spring", show_member_graphviz_url(params[:id]) )
    else
      out+= "<span class='disabled'>Spring</span>"
    end
    out+= " &nbsp;  &nbsp; "
    if not (controller.action_name == 'investigator_wheel' and controller.controller_name == 'graphviz')
      out+= link_to( "Wheel", investigator_wheel_graphviz_url(params[:id]) )
    else
      out+= "<span class='disabled'>Wheel</span>"
    end
    out+= " &nbsp;  &nbsp; "
    if not (controller.action_name == 'investigator_chord' and controller.controller_name == 'cytoscape')
      out+= link_to("Chord", investigator_chord_cytoscape_url(params[:id]))
    else
      out+= "<span class='disabled'>Chord</span>"
    end
    out+= " &nbsp;  &nbsp; "
    if defined?(LatticeGridHelper.include_awards?) and LatticeGridHelper.include_awards?() then
      if not (controller.action_name == 'awards' and controller.controller_name == 'cytoscape')
        out+= link_to('Awards', awards_cytoscape_url(params[:id]) )
      else
        out+= "<span class='disabled'>Awards</span>"
      end
      out+= " &nbsp;  &nbsp; "
    end
    if defined?(LatticeGridHelper.include_studies?) and LatticeGridHelper.include_studies?() then
      if not (controller.action_name == 'studies' and controller.controller_name == 'cytoscape')
        out+= link_to('Studies', studies_cytoscape_url(params[:id]) )
      else
        out+= "<span class='disabled'>Studies</span>"
      end
      out+= " &nbsp;  &nbsp; "
    end
    out+"</span>"
  end

  def nav_heading2()
    out="<span id='nav_links2'>"
    if (defined?(LatticeGridHelper.include_awards?) and LatticeGridHelper.include_awards?()) or (defined?(LatticeGridHelper.include_studies?) and LatticeGridHelper.include_studies?() ) then
      if not (controller.action_name == 'show_all' and controller.controller_name == 'cytoscape')
        out+= link_to( "Graph of all data", show_all_cytoscape_url(params[:id]) )
      else
        out+= "<span class='disabled'>Graph of all data</span>"
      end
      out+= " &nbsp;  &nbsp; "
      out+= "Reports: "
    end
    if defined?(LatticeGridHelper.include_awards?) and LatticeGridHelper.include_awards?() then
      if not (controller.action_name == 'investigator' and controller.controller_name == 'awards')
        out+= link_to( "Awards", investigator_award_url(params[:id]) )
      else
        out+= "<span class='disabled'>Awards</span>"
      end
      out+= " &nbsp;  &nbsp; "
    end
    if defined?(LatticeGridHelper.include_studies?) and LatticeGridHelper.include_studies?() then
      if not (controller.action_name == 'investigator' and controller.controller_name == 'studies')
        out+= link_to( "Studies", investigator_study_url(params[:id]) )
      else
        out+= "<span class='disabled'>Studies</span>"
      end
      out+= " &nbsp;  &nbsp; "
    end

    if not (controller.action_name == 'show_member_mesh' and controller.controller_name == 'graphviz')
      out+= " MeSH: "
      out+= link_to( "similarities graph", show_member_mesh_graphviz_url(params[:id]))
      out+= " &nbsp;  &nbsp; "
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
    out+="</td><td>"
    profile_link = edit_profile_link()
    unless profile_link.blank?
      out+= profile_link
      out+= " &nbsp;  &nbsp; "
    end
    if not (controller.action_name == 'show' and controller.controller_name == 'investigators')
      out+= link_to('Publications', show_investigator_url(:id=>params[:id], :page=>1) )
    else
      out+= "<span class='disabled'>Publications</span>"
    end
    out+= " &nbsp;  &nbsp; "
    if not (controller.action_name == 'investigator_wordle' and controller.controller_name == 'cytoscape')
      out+= link_to( "Word cloud", investigator_wordle_cytoscape_url(params[:id]))
    else
      out+= "<span class='disabled'>Word cloud</span>"
    end
    out+= " &nbsp; &nbsp;"
    if defined?(investigator) and ! investigator.blank?
      out+= "<span class='barchart_#{investigator.username}' id='barchart_#{investigator.username}'> &nbsp; </span>"
      out+= "<script type='text/javascript' language='javascript'>"
      out+= remote_function(:url => barchart_investigator_path( investigator.username ), :method => :get, :before => "Element.show('spinner')", :complete => "Element.hide('spinner')" )
      out+= "</script>"
    end
    out+= "<br/>"
    out+=nav_heading()
    out+= "<br/>"
    out+= nav_heading2()
    out+= "</td></tr></table>"

    out
  end

end
