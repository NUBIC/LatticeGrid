# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  begin
  include TagsHelper
  rescue
    puts "unable to load TagsHelper. Tagging plugin installed?"
  end
  require 'config'

  def handle_year(the_year=nil)
    return @year if !@year.blank? and the_year.blank?
    year_array = LatticeGridHelper.year_array()
    @year = year_array[0].to_s
    @year = cookies[:the_year] if !cookies[:the_year].blank?
    if !the_year.blank? then
      cookies[:the_year] = the_year
      @year = the_year
    end
    @year
  end

  def allowed_ip(this_ip)
     ips = LatticeGridHelper.allowed_ips() # from config.rb in project lib directory
     ips.each do |ip|
       if this_ip =~ /^#{ip}$/ then
         logger.warn "allowed_ip passed with #{this_ip}"
         return true
       end
     end
     logger.warn "allowed_ip failed #{this_ip}"
     return false  #disallowed
  end

  def capitalize_words(string) 
    string.downcase.gsub(/\b\w/) { $&.upcase } 
  end 
  
  def truncate_words(phrase, count=20) 
    return "" if phrase.blank?
    re = Regexp.new('^(.{'+count.to_s+'}\w*)(.*)', Regexp::MULTILINE)
    phrase.gsub(re) {$2.empty? ? $1 : $1 + '...'}
  end

  def abstracts_per_year(abstracts, year_array)
    years=Array.new(year_array.length, 0)
    first_year = year_array[0].to_i
    abstracts.each do |abs|
      if !abs.nil? and !abs.year.nil?
        pos = abs.year.to_i - first_year
        years[pos] = years[pos]+1 if pos >= 0 and pos < year_array.length
      end
    end
    years
  end   

  def abstracts_per_year_as_string(all_abstracts)
    abstracts_per_year(all_abstracts, LatticeGridHelper.year_array.sort).join("; ")
  end
  
  def link_to_faculty(faculty, delimiter=", ")
    faculty.collect{|pi| link_to( pi.name,
      show_investigator_url(:id=>pi.username, :page=>1), # can't use this form for usernames including non-ascii characters
      :title => " Go to #{pi.name}; #{pi.total_publications} pubs")
      }.compact.join(delimiter)
  end

  def link_to_coauthors(co_authors, delimiter=", ")
    co_authors.collect{|co_author| link_to( coauthor_span_class(co_author.colleague.name, co_author.publication_cnt),
     show_investigator_url(:id=>co_author.colleague.username, :page=>1), # can't use this form for usernames including non-ascii characters
      :title => "#{co_author.publication_cnt} shared pubs, #{co_author.colleague.total_publications} pubs, "+(co_author.colleague.num_intraunit_collaborators+co_author.colleague.num_extraunit_collaborators).to_s+" collaborators") if co_author.colleague.deleted_at.blank? }.compact.join(delimiter)
  end

  def link_to_collaborators(collaborators, delimiter=", ")
    collaborators.collect{|investigator| link_to( investigator.name, 
      show_investigator_url(:id=>investigator.username, :page=>1), # can't use this form for usernames including non-ascii characters
        :title => " #{investigator.total_publications} pubs, "+(investigator.num_intraunit_collaborators+investigator.num_extraunit_collaborators).to_s+" collaborators")  if investigator.deleted_at.blank? }.compact.join(delimiter)
  end

  def link_to_similar_investigators(relationships, delimiter=", ")
    relationships.collect{|relationship| 
      link_to( similarity_span_class(relationship.colleague.name, relationship.mesh_tags_ic.round), 
      show_investigator_url(:id=>relationship.colleague.username, :page=>1), # can't use this form for usernames including non-ascii characters
        :title => "#{relationship.mesh_tags_ic.round} similarity score, #{relationship.publication_cnt} shared pubs, #{relationship.colleague.total_publications} total pubs, "+(relationship.colleague.num_intraunit_collaborators+relationship.colleague.num_extraunit_collaborators).to_s+" collaborators") if relationship.colleague.deleted_at.blank?}.compact.join(delimiter)
  end
 
  def coauthor_span_class(link_out, score)
    similarity_class = case score
    when 41..100000
      'similarity1'
    when 20..40
      'similarity2'
    when 13..19
      'similarity3'
    when 7..12
      'similarity4'
    when 3..6
      'similarity5'
    when 1..2
      'similarity6'
    else
      'similarity7'
    end
    "<span class='#{similarity_class}'>#{link_out}</span>"
  end
  
  
  def similarity_span_class(link_out, score)
    similarity_class = case score
    when 6000..100000
      'similarity1'
    when 5000..6000
      'similarity2'
    when 4000..5000
      'similarity3'
    when 3000..4000
      'similarity4'
    when 2500..3000
      'similarity5'
    when 2000..2500
      'similarity6'
    else
      'similarity7'
    end
    "<span class='#{similarity_class}'>#{link_out}</span>"
  end
  
   
  def link_to_primary_department(investigator)
    return link_to( investigator.home_department.name, show_investigators_org_url(investigator.home_department_id), :title => "Show investigators in #{investigator.home_department.name}" ) if !investigator.home_department_id.nil?
    begin
      return investigator.home if ! investigator.home.nil?
    rescue
      ""
    end
    return ""
  end
  
  def link_to_units(appointments, delimiter="<br/>")
      appointments.collect{ |appointment| link_to_unit(appointment)}.join(delimiter)
  end
  
  def link_to_unit(unit)
    link_to( unit.name, show_investigators_org_url(unit.id), 
          :title => "Show investigators in #{unit.name}")
  end
  
  def handle_tr_format(title, object, re="", replacement="")
    return "" if object.blank?
    if re.blank?
      string=object.to_s
    else
      string=object.gsub(re,replacement)
    end
		output = "<tr><th>#{title}</th>"
		output += "<td><span id='#{title}'>#{string}</span></td>"
		output += "</tr>"
		return output
	end
	
	def email_link(email, name="")
	  return "" if email.blank?
	  return ""  if email.kind_of?(Array) and email.length == 0
	  email = email[0] if email.kind_of?(Array) and email.length > 0
	  name = email.split("@").join(" at ") if name.blank?
	  return mail_to(email, name, 
          		:subject => LatticeGridHelper.email_subject(),
          		:encode => "javascript") 
  end
  
  def handle_ldap(applicant)
    return applicant if applicant.blank? or applicant.username.blank?
    begin
      pi_data = GetLDAPentry(applicant.username) 
     # logger.warn("dump of pi_data: #{pi_data.inspect}")
      if pi_data.nil?
        logger.warn("Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null using netid #{applicant.username}.")
      elsif pi_data.blank?
          logger.warn("Entry not found. GetLDAPentry returned null using netid #{applicant.username}.")
      else
        ldap_rec=CleanPIfromLDAP(pi_data)
        applicant = BuildPIobject(ldap_rec) if applicant.id.blank?
        applicant=MergePIrecords(applicant,ldap_rec)
      end
     rescue Exception => error
      logger.error("Probable error reaching the LDAP server in GetLDAPentry: #{error.message}")
    end
    applicant
  end
    
	def hidden_div_if(condition, attributes = {}, &block)
    if condition 
      attributes["style"] = "display: none;"
    end
    content_tag("div", attributes, &block)
  end

  def image_url(source)
    abs_path = image_path(source)
    unless abs_path =~ /^http/
      abs_path = "#{request.protocol}#{request.host_with_port}#{abs_path}"
    end
   abs_path
  end
 
  def format_bool_yn(obj)
    if obj.nil? or obj.blank? or !obj
      "No"
    else
      "Yes"
    end
  end
  
  
  def link_to_pubmed(text, abstract, tooltip=nil)
    tooltip ||= text 
    link_to( text, ((abstract.url.blank?) ? "http://www.ncbi.nlm.nih.gov/pubmed/"+abstract.pubmed : abstract.url), :target => '_blank', :title=>tooltip) 
  end
end
