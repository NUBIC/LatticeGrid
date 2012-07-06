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
  
  def investigator_bio_heading(investigator, all_abstracts=nil, title=nil)
    render :partial => 'shared/investigator_bio', :locals => {:all_abstracts => all_abstracts, :title => title, :investigator => investigator}
  end
end
