
# does CCSG access require authentication?
def LatticeGridHelper.require_authentication?
  return false
end

# support editing investigator profiles? Implies that authentication is supported!
def LatticeGridHelper.allow_profile_edits?
  return false
end

# show research description
def LatticeGridHelper.show_research_description?
  return true
end

# for cancer centers to 'deselect' publications from inclusion in the CCSG report
def LatticeGridHelper.show_cancer_related_checkbox?
  return false
end

def LatticeGridHelper.build_institution_search_string_from_department?
  true
end

def LatticeGridHelper.affilation_name 
  "Institution"
end

def LatticeGridHelper.page_title
  return 'RAS Initiative Community Publications'
end

def LatticeGridHelper.header_title
  return 'The RAS Initiative Community Publications and Abstracts Site'
end

def LatticeGridHelper.menu_head_abbreviation
  "RAS"
end

def LatticeGridHelper.GetDefaultSchool()
  "RAS"
end

def LatticeGridHelper.home_url
  "http://www.cancer.gov/"
end

def LatticeGridHelper.curl_host
my_env = Rails.env
my_env = 'home' if public_path =~ /Users/ 
case 
  when my_env == 'home' then 'localhost:3000'
  when my_env == 'development' then 'rails-staging2.nubic.northwestern.edu'
  when my_env == 'staging' then 'rails-staging2.nubic.northwestern.edu'
  when my_env == 'production' then 'latticegrid.aasurg.org'
  else 'latticegrid.aasurg.org'
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
 "directory.aasurg.org"
end

def LatticeGridHelper.ldap_treebase 
 "ou=People, dc=aas,dc=org"
end

def LatticeGridHelper.include_awards?
 false
end

# build LatticeGridHelper.institutional_limit_search_string to identify all the publications at your institution 

def LatticeGridHelper.institutional_limit_search_string 
  ''
end

# limit searches to include the institutional_limit_search_string
def LatticeGridHelper.global_limit_pubmed_search_to_institution?
  false
end

def LatticeGridHelper.do_ldap?
  false
end

def latticegrid_menu_script
  
"<div id='side_nav_menu' class='ddsmoothmenu-v'>
<ul>
	<li><a href='#'>Publications by year</a>
		#{build_year_menu}
	</li>
 	<li>#{link_to( 'High Impact', high_impact_by_month_abstracts_path, :title=>'Recent high-impact publications')} </li>
	<li>#{link_to( 'MeSH tag cloud', tag_cloud_abstracts_path, :title=>'Display MeSH tag cloud for all publications')} </li>
	<li>#{link_to( 'Institution Overview', departments_orgs_path, :title => 'Display an overview of all institutions')} </li>
</ul>
<br style='clear: left' />
</div>"
end
