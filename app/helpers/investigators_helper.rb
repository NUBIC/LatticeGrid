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

  def handle_member_name(merge_ldap = true)
    return if params[:id].blank?
    if !params[:format].blank? && (params[:format] !~ /js|json|xml|pdf|xls|doc/) # reassemble the username
      params[:id] = params[:id] + '.' + params[:format]
    end
    if @investigator.blank?
      if params[:id] =~ /^[0-9]+$/
        @investigator = Investigator.include_deleted(params[:id])
      else
        @investigator = Investigator.find_by_username_including_deleted(params[:id])
      end
      if @investigator
        params[:investigator_id] = @investigator.id
        params[:name] =  @investigator.first_name + ' ' + @investigator.last_name
        merge_investigator_db_and_ldap(@investigator) if ( LatticeGridHelper.ldap_perform_search? && merge_ldap)
      else
        params[:investigator_id] = 0
        logger.error("Attempt to access invalid username (netid) #{params[:id]}")
        flash[:notice] = "Sorry - invalid username <i>#{params[:id]}</i>"
        params.delete(:id)
      end
    end
  end

  def handle_investigator_delete(investigator, do_delete = false)
    if do_delete == '1' || do_delete == true
      deleted_on = investigator.deleted_at || investigator.end_date || Time.now
      investigator.end_date = deleted_on if investigator.end_date.blank?
      investigator.deleted_at = deleted_on if investigator.deleted_at.blank?
      investigator.deleted_ip ||= request.remote_ip if defined?(request) && !request.nil?
      investigator.deleted_id ||= session[:user_id] if defined?(session) && !session.nil? && !session[:user_id].blank?
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
    params
  end

  def get_member_type(investigator)
    return 'Member' if investigator.only_member_appointments.length > 0
    return 'AssociateMember' if investigator.associate_member_appointments.length > 0
    'Member'
  end

  def merge_investigator_db_and_ldap(investigator)
    return investigator if investigator.blank? or investigator.username.blank?
    begin
      pi_data = GetLDAPentry(investigator.username)
      if pi_data.nil?
        if defined?(logger) && !logger.error.blank?
          logger.warn("Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null for #{params[:name]} using netid #{investigator.username}.")
        else
          puts "Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null for #{params[:name]} using netid #{investigator.username}."
        end
      elsif pi_data.blank?
        if defined?(logger) && ! logger.error.blank?
          logger.warn("Entry not found. GetLDAPentry returned null using netid #{investigator.username}.")
        else
          puts "Entry not found. GetLDAPentry returned null using netid #{investigator.username}."
        end
      else
        ldap_rec = CleanPIfromLDAP(pi_data)
        investigator = BuildPIobject(ldap_rec) if investigator.id.blank?
        investigator = MergePIrecords(investigator, ldap_rec)
      end
    rescue Exception => error
      if defined?(logger) and ! logger.error.blank?
        logger.error("Probable error reaching the LDAP server in GetLDAPentry: #{error.message}")
      else
        puts "Probable error reaching the LDAP server in GetLDAPentry: #{error.message}"
      end
    end
  end

  def nav_heading
    out = "<span id='nav_links'>"
    out += 'Visualizations: '
    if !(controller.action_name == 'show_member' && controller.controller_name == 'graphs')
      out += link_to('Radial1', show_member_graph_url(params[:id]))
    else
      out += "<span class='disabled'>Radial1</span>"
    end
    out += ' &nbsp;  &nbsp; '
    if !(controller.action_name == 'show' && controller.controller_name == 'cytoscape')
      out += link_to('Radial2', cytoscape_url(params[:id]))
    else
      out += "<span class='disabled'>Radial2</span>"
    end
    out += ' &nbsp;  &nbsp; '
    if !(controller.action_name == 'show_member' && controller.controller_name == 'graphviz')
      out += link_to('Spring', show_member_graphviz_url(params[:id]))
    else
      out += "<span class='disabled'>Spring</span>"
    end
    out += ' &nbsp;  &nbsp; '
    if !(controller.action_name == 'investigator_wheel' && controller.controller_name == 'graphviz')
      out += link_to('Wheel', investigator_wheel_graphviz_url(params[:id]))
    else
      out += "<span class='disabled'>Wheel</span>"
    end
    out += ' &nbsp;  &nbsp; '
    if !(controller.action_name == 'investigator_chord' && controller.controller_name == 'cytoscape')
      out += link_to('Chord', investigator_chord_cytoscape_url(params[:id]))
    else
      out += "<span class='disabled'>Chord</span>"
    end
    out += ' &nbsp;  &nbsp; '
    if defined?(LatticeGridHelper.include_awards?) && LatticeGridHelper.include_awards?
      if !(controller.action_name == 'awards' && controller.controller_name == 'cytoscape')
        out += link_to('Awards', awards_cytoscape_url(params[:id]))
      else
        out += "<span class='disabled'>Awards</span>"
      end
      out += ' &nbsp;  &nbsp; '
    end
    if defined?(LatticeGridHelper.include_studies?) && LatticeGridHelper.include_studies?
      if !(controller.action_name == 'studies' && controller.controller_name == 'cytoscape')
        out += link_to('Studies', studies_cytoscape_url(params[:id]))
      else
        out += "<span class='disabled'>Studies</span>"
      end
      out += ' &nbsp;  &nbsp; '
    end
    out += '</span>'
    out
  end

  def nav_heading2
    out = "<span id='nav_links2'>"
    if (defined?(LatticeGridHelper.include_awards?) && LatticeGridHelper.include_awards?) ||
       (defined?(LatticeGridHelper.include_studies?) && LatticeGridHelper.include_studies?)
      if controller.action_name == 'show_all' && controller.controller_name == 'cytoscape'
        out += "<span class='disabled'>Graph of all data</span>"
      else
        out += link_to('Graph of all data', show_all_cytoscape_url(params[:id]))
      end
      out += ' &nbsp;  &nbsp;<br/>'
      out += 'Reports: '
    end
    if defined?(LatticeGridHelper.include_awards?) && LatticeGridHelper.include_awards?
      if controller.action_name == 'investigator' && controller.controller_name == 'awards'
        out += "<span class='disabled'>Awards</span>"
      else
        out += link_to('Awards', investigator_award_url(params[:id]))
      end
      out += ' &nbsp;  &nbsp; '
    end
    if defined?(LatticeGridHelper.include_studies?) && LatticeGridHelper.include_studies?
      if controller.action_name == 'investigator' && controller.controller_name == 'studies'
        out += "<span class='disabled'>Studies</span>"
      else
        out += link_to('Studies', investigator_study_url(params[:id]))
      end
      out += ' &nbsp;  &nbsp; '
    end

    unless controller.action_name == 'show_member_mesh' && controller.controller_name == 'graphviz'
      out += '<br/>'
      out += ' MeSH: '
      out += link_to('Similarities graph', show_member_mesh_graphviz_url(params[:id]))
      out += ' &nbsp;  &nbsp; '
    end
    out += '</span>'
    out
  end

  def investigator_bio_heading(investigator, all_abstracts = nil, title = nil, show_barchart = true)
    out = "<table class='borderless' width='100%'><tr><td style='vertical-align: top; width: 35em'>"
    out += "<span id='full_name'>#{investigator.full_name}</span>" if defined?(investigator) && !investigator.blank?
    out += "<br/><span id='page_title'>#{title}</span>" if defined?(title) && !title.blank?
    out += '</td><td>'
    profile_link = edit_profile_link
    unless profile_link.blank?
      out += profile_link
      out += ' &nbsp;  &nbsp; '
    end
    if !(controller.action_name == 'show' && controller.controller_name == 'investigators')
      out += link_to('Publications', show_investigator_url(id: params[:id], page: 1))
    else
      out += "<span class='disabled'>Publications</span>"
    end
    out += ' &nbsp;  &nbsp; '
    if !(controller.action_name == 'investigator_wordle' && controller.controller_name == 'cytoscape')
      out += link_to('Word cloud', investigator_wordle_cytoscape_url(params[:id]))
    else
      out += "<span class='disabled'>Word cloud</span>"
    end
    out += ' &nbsp;  &nbsp; '
    if show_barchart && defined?(investigator) && !investigator.blank?
      out += "<span class='barchart_#{investigator.username}' id='barchart_#{investigator.username}'> &nbsp; </span>"
      out += "<script type='text/javascript' language='javascript'>"
      out += remote_function(url: barchart_investigator_path(investigator.username), method: :get)
      out += '</script>'
    end
    out += "#{nav_heading}#{nav_heading2}"
    out += '</td></tr></table>'
    out
  end

end
