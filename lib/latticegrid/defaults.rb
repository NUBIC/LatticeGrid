  # class methods
  
  def LatticeGridHelper.page_title
    return 'LatticeGrid Publications'
  end

  def LatticeGridHelper.header_title
    return 'LatticeGrid Publications and Abstracts Site'
  end
  
  def LatticeGridHelper.direct_preview_title
     'LatticeGrid Publications'
  end
  
  # does CCSG access require authentication?
  def LatticeGridHelper.require_authentication?
    return false
  end

  # support editing investigator profiles? Implies that authentication is supported!
  def LatticeGridHelper.allow_profile_edits?
    return false
  end

  def LatticeGridHelper.include_summary_by_member?
    return false
  end

  # for cancer centers to 'deselect' publications from inclusion in the CCSG report
  def LatticeGridHelper.show_cancer_related_checkbox?
    return false
  end

   # show research description
   def LatticeGridHelper.show_research_description?
     return true
   end

   def LatticeGridHelper.menu_head_abbreviation
     "Lurie Cancer Center"
   end

   def LatticeGridHelper.GetDefaultSchool()
     "Feinberg"
   end

   def LatticeGridHelper.CachePages()
     true
   end

   def LatticeGridHelper.curl_host
   	my_env = Rails.env
   	my_env = 'home' if public_path =~ /Users/ 
   	case 
   	  when my_env == 'home': 'localhost:3000'
   	  when my_env == 'development': 'rails-staging2.nubic.northwestern.edu'
   	  when my_env == 'staging': 'rails-staging2.nubic.northwestern.edu'
   	  when my_env == 'production': 'latticegrid.cancer.northwestern.edu'
   	  else 'rails-dev.bioinformatics.northwestern.edu/cancer'
   	end 
   end

   def LatticeGridHelper.curl_protocol
   	my_env = Rails.env
   	my_env = 'home' if public_path =~ /Users/ 
   	case 
   	  when my_env == 'home': 'http'
   	  when my_env == 'development': 'https'
   	  when my_env == 'staging': 'https'
   	  when my_env == 'production': 'https'
   	  else 'http'
   	end 
   end

  def LatticeGridHelper.year_array
    return @@year_array if defined?(@@year_array)
    starting_year=Time.now.year
    @@year_array = (starting_year-9 .. starting_year).to_a
    @@year_array.reverse!
    return @@year_array
  end

  def LatticeGridHelper.email_subject
    "Contact from the LatticeGrid Publications site at the Northwestern Robert H. Lurie Comprehensive Cancer Center"
  end

  def LatticeGridHelper.home_url
    "http://www.cancer.northwestern.edu"
    "http://wiki.bioinformatics.northwestern.edu/index.php/LatticeGrid"
  end

   def LatticeGridHelper.cleanup_campus(thePI)
     #clean up the campus data
     thePI.campus = (thePI.campus =~ /CH|Chicago/) ? 'Chicago' : thePI.campus
     thePI.campus = (thePI.campus =~ /EV|Evanston/) ? 'Evanston' : thePI.campus
     thePI.campus = (thePI.campus =~ /CMH|Children/) ? 'CMH' : thePI.campus
     thePI
   end

   def LatticeGridHelper.do_ajax?
     (is_admin? and Rails.env != 'production') ? false : true
     true
   end

   def LatticeGridHelper.do_ldap?
     (is_admin? and Rails.env != 'production') ? false : true
     true
   end


   def LatticeGridHelper.ldap_perform_search?
     true
   end

   def LatticeGridHelper.ldap_host
     "directory.northwestern.edu"
   end

   def LatticeGridHelper.ldap_treebase 
     "ou=People, dc=northwestern,dc=edu"
   end

   def LatticeGridHelper.include_awards?
     false
   end

   def LatticeGridHelper.include_studies?
     false
   end

   def LatticeGridHelper.allowed_ips
     # childrens: 199.125.
     # nmff: 209.107.
     # nmh: 165.20.
     # enh: 204.26
     # ric: 69.216
     [':1','127.0.0.*','165.124.*','129.105.*','199.125.*','209.107.*','165.20.*','204.26.*','69.216.*']
   end
   


 def LatticeGridHelper.setInvestigatorClass(citation,investigator, isMember=false)
   if isMember
     if isInvestigatorLastAuthor(citation,investigator) : "member_last_author" 
     elsif isInvestigatorFirstAuthor(citation,investigator) : "member_first_author"
     else
       "member_author"
     end
   else
     if isInvestigatorLastAuthor(citation,investigator) : "last_author" 
     elsif isInvestigatorFirstAuthor(citation,investigator) : "first_author"
     else
       "author"
     end
   end
 end


def LatticeGridHelper.getFirstAuthorIDForCitation(citation)
  citation.investigator_abstracts.each do |investigator_abstract|
    return investigator_abstract.investigator_id if investigator_abstract.is_first_author
  end
  return nil
end

def LatticeGridHelper.getFirstAuthorForCitation(citation)
  author_id = getFirstAuthorIDForCitation(citation)
  return nil if author_id.blank?
  citation.investigators.each do |investigator|
    return investigator if investigator.id == author_id
  end
  return nil
end

def LatticeGridHelper.getLastAuthorIDForCitation(citation)
  citation.investigator_abstracts.each do |investigator_abstract|
    return investigator_abstract.investigator_id if investigator_abstract.is_last_author
  end
  return nil
end

def LatticeGridHelper.getLastAuthorForCitation(citation)
  author_id = getLastAuthorIDForCitation(citation)
  return nil if author_id.blank?
  citation.investigators.each do |investigator|
    return investigator if investigator.id == author_id
  end
  return nil
end

def LatticeGridHelper.isInvestigatorFirstAuthor(citation,investigator)
  if getFirstAuthorForCitation(citation) == investigator
    return true
  end
  return false
end

def LatticeGridHelper.isInvestigatorLastAuthor(citation,investigator)
  if getLastAuthorForCitation(citation) == investigator
    return true
  end
  return false
end

# LatticeGrid prefs:
# turn on lots of output
def LatticeGridHelper.debug?
  false
end

# try multiple searches if a search returns too many or too few publications
def LatticeGridHelper.smart_filters?
  true
end


# print timing and completion information
def LatticeGridHelper.verbose?
  true
end

# limit searches to include the institutional_limit_search_string
def LatticeGridHelper.global_limit_pubmed_search_to_institution?
  true
end

# use full first name in PubMed searches
def LatticeGridHelper.global_pubmed_search_full_first_name?
  true
end

# build LatticeGridHelper.institutional_limit_search_string to identify all the publications at your institution 

def LatticeGridHelper.institutional_limit_search_string 
  '( "Northwestern University"[affil] OR "Feinberg School"[affil] OR "Robert H. Lurie Comprehensive Cancer Center"[affil] OR "Northwestern Healthcare"[affil] OR "Children''s Memorial"[affil] OR "Northwestern Memorial"[affil] OR "Northwestern Medical"[affil])'
end

# these names will always be limited to the institutional search only even if LatticeGridHelper.global_limit_pubmed_search_to_institution?` is false
def LatticeGridHelper.last_names_to_limit
  ["Brown","Chen","Das","Khan","Li","Liu","Lu","Lee","Shen","Smith","Tu","Wang","Xia","Yang","Zhou"]
end

# these are for messages regarding the expected number of publications
def LatticeGridHelper.expected_min_pubs_per_year
  1
end

def LatticeGridHelper.expected_max_pubs_per_year
  30
end

# you shouldn't need to change these ...
def LatticeGridHelper.all_years
  10
end

def LatticeGridHelper.default_number_years
  1
end

def LatticeGridHelper.default_fill_color
  '#A28BA9'
end

def LatticeGridHelper.white_fill_color
  '#FFFFFF'
end

def LatticeGridHelper.root_fill_color
  '#FFAD33'
end

def LatticeGridHelper.root_other_fill_color
  '#E8A820'
end

# pale gold
def LatticeGridHelper.first_degree_fill_color
  '#FFE0C2'
end

# pale violet grey - E6E0E8
# pale avacado greeen
def LatticeGridHelper.first_degree_other_fill_color
  '#CAD4B8'
end

# pale gold - FFE9BF
def LatticeGridHelper.second_degree_fill_color
  '#FFFFCC'
end

# pale blue green
def LatticeGridHelper.second_degree_other_fill_color
  '#A3DADA'
end

# super pale green 
def LatticeGridHelper.second_degree_other_fill_color
  '#CCF5CC'
end


# must be instance methods, not class methods

  # profile example summaries
  def profile_example_summaries()
     out = "<p>Example summaries:"  
    out << "<ul>"
    out << "<li>"
    out << link_to("Cancer Control Example", investigator_url('rbe510'))
    out << "<li>"
    out << link_to("Basic Science Example", investigator_url('tvo')) 
    out << "<li>"
    out << link_to("Clinical Program Example", investigator_url('lpl530'))
    out << "</ul>"
    out << "</p>"
    out
  end

  # citation style
  def format_citation(publication, link_abstract_to_pubmed=false, mark_members_bold=false, investigators_in_unit=[], speed_display=false, simple_links=false)
  #  out = publication.authors
    out = (mark_members_bold) ? highlightMemberInvestigator(publication, speed_display, simple_links, investigators_in_unit) : highlightInvestigator(publication, speed_display, simple_links)
    out << " "
    if link_abstract_to_pubmed
  	out << link_to( publication.title, "http://www.ncbi.nlm.nih.gov/pubmed/"+publication.pubmed, :target => '_blank', :title=>'PubMed ID')
    else
  	out << link_to( publication.title, abstract_url(publication))
    end 
    out << "<i>#{publication.journal_abbreviation}</i> "
    out << " (#{publication.year}) "
    if publication.pages.length > 0
  	out << h(publication.volume) +":"+ h(publication.pages)+"."
    else
  	out << "<i>In process.</i>"
    end
  end

def link_to_investigator(citation, investigator, name=nil, isMember=false, speed_display=false, simple_links=false) 
   name=investigator.last_name if name.blank?
  link_to( name, 
   show_investigator_url(:id=>investigator.username, :page=>1), # can't use this form for usernames including non-ascii characters
     :class => ((speed_display) ? 'author' : LatticeGridHelper.setInvestigatorClass(citation, investigator, isMember)),
     :title => (simple_links ? "Go to #{investigator.name}: #{investigator.total_publications} pubs" : "Go to #{investigator.name}: #{investigator.total_publications} pubs, " + (investigator.num_intraunit_collaborators+investigator.num_extraunit_collaborators).to_s+" collaborators") )
end

  # investigator highlighting
  def highlightMemberInvestigator(citation, speed_display=false, simple_links=false, memberArray=nil)
    if memberArray.blank?
  	authors = highlightInvestigator(citation, speed_display, simple_links)
    else
  	authors = highlightInvestigator(citation, speed_display, simple_links, citation.authors, memberArray)
    end
    authors
  end

  def highlightInvestigator(citation, speed_display=false, simple_links=false, authors=nil,memberArray=nil)
    if authors.blank?
  	authors = citation.authors
    end
    #authors = authors.gsub(", "," ")
    #authors = authors.gsub(/\. ?/,"")
    citation.investigators.each do |investigator|
  	re = Regexp.new('('+investigator.last_name.downcase+', '+investigator.first_name.at(0).downcase+'[^;\n]*)', Regexp::IGNORECASE)
  	isMember = (!memberArray.blank? and memberArray.include?(investigator.id))
  	authors.gsub!(re){|author_match| link_to_investigator(citation, investigator, author_match.gsub(" ","| "), isMember, speed_display, simple_links)}
    end
    authors = authors.gsub("|","")
    authors = authors.gsub("\n","; ")
    authors
  end

  def edit_profile_link
    link_to("Edit profile", profiles_path, :title=>"Login with your NetID and NetID password to change your profile")
  end

   def menu_script
   "<div id='side_nav_menu' class='ddsmoothmenu-v'>
   <ul>
   	<li><a href='#'>Publications by year</a>
   		#{build_year_menu}
   	</li>
   	<li><a href='#'>Publications by program</a>
   		#{build_menu(@head_node.children.sort_by(&:abbreviation), Program) {|id| org_path(id)} }
   	</li>
   	<li><a href='#'>Faculty by program</a>
   		#{build_menu(@head_node.children.sort_by(&:abbreviation), Program) {|id| show_investigators_org_path(id)} }
   	</li>
   	<li><a href='#'>Graphs by program</a>
   		#{build_menu(@head_node.children.sort_by(&:abbreviation), Program) {|id| show_org_graph_path(id)} }
   	</li>
   	<li>#{link_to( 'MeSH tag cloud', tag_cloud_abstracts_path, :title=>'Display MeSH tag cloud for all publications')} </li>
   	<li>#{link_to( 'Overview', programs_orgs_path, :title => 'Display an overview for all programs')}</li>
   </ul>
   <br style='clear: left' />
   </div>"
   end

   def build_menu(nodes, org_type=nil, &block)
     out="<ul>"
 		for unit in nodes
 		  if org_type.nil? or unit.kind_of?(org_type)
     		out+="<li>"
     		out+=link_to( truncate(unit.name.gsub(/\'/, ""),:length=>80), yield(unit.id))
         out+=build_menu(unit.children, nil, &block) if ! unit.leaf?
     		out+="</li>"
   		end
 		end
 		out+="</ul>"
 		out
 	end

  def build_year_menu
     out="<ul>"
 		for the_year in LatticeGridHelper.year_array()
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

  def is_admin?
    begin
      if [ 'wakibbe', 'admin', 'tvo743', 'jkk366', 'jhl197', 'ddc830', 'mar352' ].include?(current_user.username.to_s)  then
    	  return true
      end
    rescue
      begin
        logger.error "is_admin? threw an error on include?(current_user.username.to_s) "
      rescue
        puts "is_admin? threw an error on include?(current_user.username.to_s) "
      end
    end
    return false
  end


