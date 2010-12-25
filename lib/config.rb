
# does CCSG access require authentication?
def require_authentication?
  return false
end

# support editing investigator profiles? Implies that authentication is supported!
def allow_profile_edits?
  return false
end

# for cancer centers to 'deselect' publications from inclusion in the CCSG report
def show_cancer_related_checkbox?
  return true
end

# show research description
def show_research_description?
  return false
end

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
def display_citation(publication, link_abstract_to_pubmed=false, mark_members_bold=false, investigators_in_unit=[])
  out = (mark_members_bold) ? highlightMemberInvestigator(publication,investigators_in_unit) : highlightInvestigator(publication)
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

# investigator highlighting
def highlightMemberInvestigator(citation,memberArray=nil)
  if memberArray.blank?
    authors = highlightInvestigator(citation)
  else
    authors = highlightInvestigator(citation,citation.authors,memberArray)
  end
  authors
end

def highlightInvestigator(citation, authors=nil,memberArray=nil)
  if authors.blank?
    authors = citation.authors
  end
  #authors = authors.gsub(", "," ")
  #authors = authors.gsub(/\. ?/,"")
  citation.investigators.each do |investigator|
    re = Regexp.new('('+investigator.last_name.downcase+', '+investigator.first_name.at(0).downcase+'[^;\n]*)', Regexp::IGNORECASE)
    isMember = (!memberArray.blank? and memberArray.include?(investigator.id))
    authors.gsub!(re){|author_match| link_to_investigator(citation, investigator, author_match.gsub(" ","| "), isMember)}
  end
  authors = authors.gsub("|","")
  authors = authors.gsub("\n","; ")
  authors
end

def menu_head_abbreviation
  "Lurie Cancer Center"
end

def title_abbreviation
  "Lurie Cancer Center"
end

def GetDefaultSchool()
  "Feinberg"
end

def CachePages()
  true
end

def curl_host
    my_env = RAILS_ENV
    my_env = 'home' if public_path =~ /Users/ 
	case 
      when my_env == 'home': 'localhost:3000'
      when my_env == 'development': 'rails-dev.bioinformatics.northwestern.edu'
      when my_env == 'production': 'latticegrid.cancer.northwestern.edu'
      else 'rails-dev.bioinformatics.northwestern.edu/cancer'
	end 
end

def email_subject
  "Contact from the LatticeGrid Publications site at the Northwestern Robert H. Lurie Comprehensive Cancer Center"
end

def cleanup_campus(thePI)
  #clean up the campus data
  thePI.campus = (thePI.campus =~ /CH|Chicago/) ? 'Chicago' : thePI.campus
  thePI.campus = (thePI.campus =~ /EV|Evanston/) ? 'Evanston' : thePI.campus
  thePI.campus = (thePI.campus =~ /CMH|Children/) ? 'CMH' : thePI.campus
  thePI
end

def edit_profile_link
 ""
end

def is_admin?
  return false if defined?(current_user) == nil
  if [ 'wakibbe', 'admin', 'tvo743', 'jkk366', 'jhl197', 'ddc830' ].include?(current_user.username)  then
      return true
  end
  return false
end

def do_ajax?
  (is_admin? and ENV['RAILS_ENV'] != 'production') ? false : true
  true
end

def do_ldap?
  (is_admin? and ENV['RAILS_ENV'] != 'production') ? false : true
  true
end
