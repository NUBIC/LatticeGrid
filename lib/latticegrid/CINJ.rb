
# does CCSG access require authentication?
def LatticeGridHelper.require_authentication?
  return false
end

# support editing investigator profiles? Implies that authentication is supported!
def LatticeGridHelper.allow_profile_edits?
  return false
end

# allowed membership types
def LatticeGridHelper.allowed_membership_types
  return ['Member', 'AssociateMember']
end

def edit_profile_link
  ""
end

# for cancer centers to 'deselect' publications from inclusion in the CCSG report
def LatticeGridHelper.show_cancer_related_checkbox?
  return true
end

def LatticeGridHelper.page_title
  return 'CINJ Faculty Publications'
end

def LatticeGridHelper.header_title
  return 'CINJ Member Publications and Abstracts Site'
end

def LatticeGridHelper.menu_head_abbreviation
  "The Cancer Institute of New Jersey"
end

def LatticeGridHelper.GetDefaultSchool()
  "UMDNJ"
end

def LatticeGridHelper.email_subject
  "Contact from the LatticeGrid Publications site at the Cancer Institute of New Jersey"
end


def LatticeGridHelper.home_url
  "http://www.cinj.org/"
end

def LatticeGridHelper.curl_host
my_env = Rails.env
my_env = 'home' if public_path =~ /Users/ 
case 
  when my_env == 'home' then 'localhost:3000'
  when my_env == 'development' then 'rails-staging2.nubic.northwestern.edu'
  when my_env == 'staging' then 'rails-staging2.nubic.northwestern.edu'
  when my_env == 'production' then 'latticegrid.cinj.org'
  else 'latticegrid.cinj.org'
end 
end

def LatticeGridHelper.curl_protocol
my_env = Rails.env
my_env = 'home' if public_path =~ /Users/ 
case 
  when my_env == 'home' then 'http'
  when my_env == 'development' then 'http'
  when my_env == 'staging' then 'http'
  when my_env == 'production' then 'http'
  else 'http'
end 
end

def profile_example_summaries()
  ""
end

def LatticeGridHelper.do_ldap?
 (is_admin? and Rails.env != 'production') ? false : true
 false
end


def LatticeGridHelper.ldap_perform_search?
 false
end

def LatticeGridHelper.ldap_host
 "directory.cinj.org"
end

def LatticeGridHelper.ldap_treebase 
 "ou=People, dc=cinj,dc=org"
end

def LatticeGridHelper.include_awards?
  false
end

def LatticeGridHelper.include_studies?
  false
end

# build LatticeGridHelper.institutional_limit_search_string to identify all the publications at your institution 

def LatticeGridHelper.institutional_limit_search_string 
  '("The Cancer Institute of New Jersey "[affil] or "UMDNJ"[affil] or ("University"[affil] AND "New Jersey"[affil]) or "Robert Wood Johnson"[affil] or "Rutgers"[affil])'
end

def format_citation(publication, link_abstract_to_pubmed=false, mark_members_bold=false, investigators_in_unit=[], speed_display=false, simple_links=false)
  #  out = publication.authors
    out = (mark_members_bold) ? highlightMemberInvestigator(publication, speed_display, simple_links, investigators_in_unit) : highlightInvestigator(publication, speed_display, simple_links)
    out << ". "
    if link_abstract_to_pubmed
  	out << link_to( publication.title, "http://www.ncbi.nlm.nih.gov/pubmed/"+publication.pubmed, :target => '_blank', :title=>'PubMed ID')
    else
  	out << link_to( publication.title, abstract_url(publication))
    end 
  out << " "
  out << publication.journal_abbreviation
  out << ", "
  if publication.pages.length > 0
    out << "<i>"+h(publication.volume) +"</i>:"+ h(publication.pages)
  else
  	out << "<i>In process</i>"
  end
  out << ", #{publication.year}."
end

def highlightInvestigator(citation, speed_display=false, simple_links=false, authors=nil,memberArray=nil)
  if authors.blank?
    authors = citation.authors
  end
  authors = authors.gsub(", "," ")
  authors = authors.gsub(/\. ?/,"")
  citation.investigators.each do |investigator|
    re = Regexp.new('('+investigator.last_name.downcase+' '+investigator.first_name.at(0).downcase+'[^,\n]*)', Regexp::IGNORECASE)
    isMember = (!memberArray.blank? and memberArray.include?(investigator.id))
    authors.gsub!(re){|author_match| link_to_investigator(citation, investigator, author_match.gsub(" ","| "), isMember, speed_display, simple_links)}
  end
  authors = authors.gsub("|","")
  authors = authors.gsub("\n",", ")
  authors
end

# limit searches to include the institutional_limit_search_string
def LatticeGridHelper.global_limit_pubmed_search_to_institution?
  false
end

def LatticeGridHelper.do_ldap?
  false
end
