# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  begin
  include TagsHelper
  rescue
    puts "unable to load TagsHelper. Tagging plugin installed?"
  end
  require 'config'
    
  def build_menu(nodes, org_type=nil, &block)
    out="<ul>"
		for unit in nodes
		  if org_type.nil? or unit.kind_of?(org_type)
    		out+="<li>"
    		out+=link_to( unit.abbreviation.gsub(/\'/, ""), yield(unit.id))
        out+=build_menu(unit.children, nil, &block) if ! unit.leaf?
    		out+="</li>"
  		end
		end
		out+="</ul>"
		out
	end
  
  def build_year_menu
    out="<ul>"
		for the_year in @year_array
			if  controller.action_name.match('year_list') != nil && the_year.to_s == @year
				out+="<li class='current'>"
			else
    		out+="<li>"
			end
			out+=link_to( the_year, abstracts_by_year_url(:id => the_year, :page=> 1))
   		out+="</li>"
		end
		out+="</ul>"
		out
	end
	
  def capitalize_words(string) 
    string.downcase.gsub(/\b\w/) { $&.upcase } 
  end 
  
  def  trunc_and_join_array(array, count=20, delimiter=", ")
    if array.length > count.to_i
      array[0,count.to_i].join(delimiter)+'…'
    else
      array.join(delimiter)
    end
  end

  def truncate_words(phrase, count=20) 
    re = Regexp.new('^(.{'+count.to_s+'}\w*)(.*)', Regexp::MULTILINE)
    phrase.gsub(re) {$2.empty? ? $1 : $1 + '...'}
  end

  def abstracts_per_year(abstracts, year_array)
    years=Array.new(year_array.length, 0)
    first_year = year_array[0]
    abstracts.each do |abs|
      pos = abs.year.to_i - first_year.to_i
      years[pos]=years[pos]+1 if pos >= 0
    end
    years
  end   

  def isInvestigatorFirstAuthor(citation,investigator)
    if getFirstAuthorForCitation(citation) == investigator
      return true
    end
    return false
  end

  def isInvestigatorLastAuthor(citation,investigator)
    if getLastAuthorForCitation(citation) == investigator
      return true
    end
    return false
   end
  
  def setInvestigatorClass(citation,investigator)
    if isInvestigatorLastAuthor(citation,investigator) : "last_author" 
    elsif isInvestigatorFirstAuthor(citation,investigator) : "first_author"
    else
      "author"
    end
  end

  def link_to_coauthors(coauthors, delimiter=", ")
    coauthors.collect{|coauthor| link_to( coauthor.colleague.name, 
      show_investigator_url(:id=>coauthor.colleague.username, :page=>1), # can't use this form for usernames including non-ascii characters
        :title => " #{coauthor.colleague.abstract_count} pubs, "+(coauthor.colleague.num_intraunit_collaborators+coauthor.colleague.num_extraunit_collaborators).to_s+" collaborators")}.join(delimiter)
  end

  def link_to_collaborators(collaborators, delimiter=", ")
    collaborators.collect{|investigator| link_to( investigator.name, 
      show_investigator_url(:id=>investigator.username, :page=>1), # can't use this form for usernames including non-ascii characters
        :title => " #{investigator.abstract_count} pubs, "+(investigator.num_intraunit_collaborators+investigator.num_extraunit_collaborators).to_s+" collaborators")}.join(delimiter)
  end
  
  def link_to_similar_investigators(relationships, delimiter=", ")
    relationships.collect{|relationship| link_to( "#{relationship.colleague.name} <span class='simularity'>#{relationship.mesh_tags_ic.round}</span>", 
      show_investigator_url(:id=>relationship.colleague.username, :page=>1), # can't use this form for usernames including non-ascii characters
        :title => " #{relationship.colleague.abstract_count} pubs, "+(relationship.colleague.num_intraunit_collaborators+relationship.colleague.num_extraunit_collaborators).to_s+" collaborators")}.join(delimiter)
  end
  
  def link_to_investigator(citation, investigator, name=nil) 
    name=investigator.last_name if name.blank?
    link_to name, 
      show_investigator_url(:id=>investigator.username, :page=>1), # can't use this form for usernames including non-ascii characters
      :class => setInvestigatorClass(citation,investigator),
      :title => "Go to #{name}: #{investigator.abstract_count} pubs, "+(investigator.num_intraunit_collaborators+investigator.num_extraunit_collaborators).to_s+" collaborators"
  end
  
  def getFirstAuthorIDForCitation(citation)
    citation.investigator_abstracts.each do |investigator_abstract|
      return investigator_abstract.investigator_id if investigator_abstract.is_first_author
    end
    return nil
  end

  def getFirstAuthorForCitation(citation)
    author_id = getFirstAuthorIDForCitation(citation)
    return nil if author_id.blank?
    citation.investigators.each do |investigator|
      return investigator if investigator.id == author_id
    end
    return nil
  end

  def getLastAuthorIDForCitation(citation)
    citation.investigator_abstracts.each do |investigator_abstract|
      return investigator_abstract.investigator_id if investigator_abstract.is_last_author
    end
    return nil
  end

  def getLastAuthorForCitation(citation)
    author_id = getLastAuthorIDForCitation(citation)
    return nil if author_id.blank?
    citation.investigators.each do |investigator|
      return investigator if investigator.id == author_id
    end
    return nil
  end

  def author_name(author)
    author.last_name+',  '+author.first_name.at(0)+(author.middle_name.blank? ? '' : author.middle_name.at(0) )
  end
    
  def highlightInvestigator(citation, authorList=nil)
    if authorList.blank?
      authors = citation.authors.gsub("\n","; ")
    else
      authors = authorList.gsub("\n","; ")
    end
    citation.investigators.each do |investigator|
      re = Regexp.new('('+investigator.last_name.downcase+', '+investigator.first_name.at(0).downcase+'[^;]+)', Regexp::IGNORECASE) 
      authors.gsub!(re){|match| link_to_investigator(citation, investigator, author_name(investigator))}
    end
    authors
  end
  
  def markProgramMembership(citation, programID)
    if citation.investigators.length > 1 then
      getMembershipMarker(citation,programID)
    end
  end

  def getMembershipMarker(citation,programID)
    intra=0
    inter=0
    marker=""
    citation.investigators.each do |investigator|
      if investigator.investigator_programs.has_program(programID) then
        intra+=1
      else
        inter+=1
      end
    end
    marker="*" if intra > 1
    marker=marker+" §" if inter > 0
    return marker
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
      appointments.collect{ |appointment| 
          link_to( appointment.name, show_investigators_org_url(appointment.id), 
          :title => "Show investigators in #{appointment.name}")}.join(delimiter)
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
	
	def email_link(email)
	  return "" if email.blank?
	  return mail_to(email, email.split("@").join(" at "), 
          		:subject => email_subject(),
          		:encode => "javascript") 
  end
  
  def handle_ldap(applicant)
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
end
