
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

def LatticeGridHelper.year_array
  return @@year_array if defined?(@@year_array)
  starting_year=Time.now.year
  @@year_array = (starting_year-34 .. starting_year).to_a
  @@year_array.reverse!
  return @@year_array
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
  when my_env == 'development' then 'ras.ucsf.edu'
  when my_env == 'staging' then 'ras.ucsf.edu'
  when my_env == 'production' then 'ras.ucsf.edu'
  else 'ras.ucsf.edu'
end 
end

def LatticeGridHelper.curl_protocol
my_env = Rails.env
my_env = 'home' if public_path =~ /Users/ 
case 
  when my_env == 'home' then 'http:'
  when my_env == 'development' then 'https'
  when my_env == 'staging' then 'https'
  when my_env == 'production' then 'https'
  else 'https'
end 
end

def profile_example_summaries()
  ""
end

def LatticeGridHelper.do_ldap?
 (is_admin? and Rails.env != 'production') ? false : true
 false
end

def LatticeGridHelper.limit_to_MeSH_terms?
  true
end

def LatticeGridHelper.MeSH_terms_string
  '("genes, ras"[MeSH Terms] OR ("genes"[All Fields] AND "ras"[All Fields]) OR "ras genes"[All Fields] OR ("ras"[All Fields] AND "genes"[All Fields])) OR ("ras proteins"[MeSH Terms] OR ("ras"[All Fields] AND "proteins"[All Fields]) OR "ras proteins"[All Fields]) OR (("oncogene proteins"[MeSH Terms] OR ("oncogene"[All Fields] AND "proteins"[All Fields]) OR "oncogene proteins"[All Fields] OR ("oncogene"[All Fields] AND "protein"[All Fields]) OR "oncogene protein"[All Fields]) AND p21ras[All Fields]) OR (("proto-oncogene proteins"[MeSH Terms] OR ("proto-oncogene"[All Fields] AND "proteins"[All Fields]) OR "proto-oncogene proteins"[All Fields] OR ("proto"[All Fields] AND "oncogene"[All Fields] AND "proteins"[All Fields]) OR "proto oncogene proteins"[All Fields]) AND p21ras[All Fields]) OR ("ras gtpase-activating proteins"[MeSH Terms] OR ("ras"[All Fields] AND "gtpase-activating"[All Fields] AND "proteins"[All Fields]) OR "ras gtpase-activating proteins"[All Fields] OR ("ras"[All Fields] AND "gtpase"[All Fields] AND "activating"[All Fields] AND "proteins"[All Fields]) OR "ras gtpase activating proteins"[All Fields]) OR ("ras-grf1"[MeSH Terms] OR "ras-grf1"[All Fields] OR ("ras"[All Fields] AND "grf1"[All Fields]) OR "ras grf1"[All Fields])'
end

def LatticeGridHelper.MeSH_terms_array
  ["ras genes[MeSH Terms]", "ras proteins[MeSH Terms]", "p21ras", "ras gtpase-activating proteins", "ras-grf1", "ras GTPase-Activating Proteins[nm]"]
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

# use full first name in PubMed searches
def LatticeGridHelper.global_pubmed_search_full_first_name?
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

def edit_profile_link
  ""
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
