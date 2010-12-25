module InvestigatorsHelper
  require 'ldap_utilities' #specific ldap methods
  require 'config' #heading configuration options
  
  def handle_member_name
    return if params[:id].blank?
    if !params[:format].blank? then #reassemble the username
      params[:id]=params[:id]+"."+params[:format]
    end
    if params[:name].blank? then
      @investigator = Investigator.find_by_username_including_deleted(params[:id])
      if @investigator
        params[:investigator_id] = @investigator.id
        params[:name] =  @investigator.first_name + " " + @investigator.last_name
        merge_investigator_db_and_ldap(@investigator) if ldap_perform_search?
      else
        logger.error("Attempt to access invalid username (netid) #{params[:id]}") 
        flash[:notice] = "Sorry - invalid username <i>#{params[:id]}</i>"
        params.delete(:id)
      end
    end
  end
  
  def merge_investigator_db_and_ldap(investigator)
    begin
      pi_data = GetLDAPentry(investigator.username)
      if pi_data.nil?
        logger.warn("Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null for #{params[:name]} using netid #{investigator.username}.")
      else
        ldap_rec=CleanPIfromLDAP(pi_data)
        investigator=MergePIrecords(investigator,ldap_rec)
      end
    rescue Exception => error
      logger.error("Probable error reaching the LDAP server in GetLDAPentry: #{error.message}")
    end
  end
  
  def investigator_bio_heading(investigator, all_abstracts=nil)
    out="<span id='full_name'>"
    out+=investigator.full_name
    out+="</span>"
    out+=" &nbsp;  &nbsp; "
    if not (controller.action_name == 'show' and controller.controller_name == 'investigators')
      out+= link_to('Investigator publications', investigator_url(:id=>params[:id], :page=>1) ) 
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show_member' and controller.controller_name == 'graph')
      out+= link_to('Interactions graph', show_member_graph_url(params[:id]) ) 
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show_member' and controller.controller_name == 'graphviz')
      out+= link_to( "Interactions network", show_member_graphviz_url(params[:id]) )
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show_member_mesh' and controller.controller_name == 'graphviz')
      out+= link_to( "MeSH similarities network", show_member_mesh_graphviz_url(params[:id]))
      out+= " &nbsp;  &nbsp; "  
    end
    out+= edit_profile_link
    out+= " &nbsp;  &nbsp; "
    if defined?(all_abstracts) and ! all_abstracts.nil? and all_abstracts.length > 10
      out+= "<a href='' title='publications per year'> #{sparkline_tag( abstracts_per_year(all_abstracts, @year_array.sort), :type => 'bar')}</a>"
    end
    out
  end
  
end
