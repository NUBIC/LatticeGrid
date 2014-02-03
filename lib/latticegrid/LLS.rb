def LatticeGridHelper.menu_head_abbreviation
  "LLS"
end

def LatticeGridHelper.get_default_school
  "LLS"
end

def LatticeGridHelper.page_title
  return 'Leukemia and Lymphoma Society Publications'
end

def LatticeGridHelper.header_title
  return 'Leukemia and Lymphoma Society Publications and Abstracts Site'
end

def LatticeGridHelper.direct_preview_title
   ''
end

def LatticeGridHelper.home_url
  "http://lls.org"
end

def LatticeGridHelper.organization_name
  "Leukemia and Lymphoma Society"
end

def LatticeGridHelper.curl_host
	my_env = Rails.env
	my_env = 'home' if public_path =~ /Users/
	case
	  when my_env == 'home' then 'localhost:3000'
	  when my_env == 'development' then 'rails-staging2.nubic.northwestern.edu'
	  when my_env == 'staging' then 'rails-staging2.nubic.northwestern.edu'
	  when my_env == 'production' then 'latticegrid.lls.org'
	  else 'rails-dev.bioinformatics.northwestern.edu/lls_pubs'
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

def LatticeGridHelper.include_awards?
  false
end

def LatticeGridHelper.include_studies?
  false
end

def edit_profile_link
  ""
end

# limit searches to include the institutional_limit_search_string
def LatticeGridHelper.global_limit_pubmed_search_to_institution?
  false
end

def LatticeGridHelper.mark_full_name_searches_as_valid?
  true
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
 	<li>#{link_to( 'Faculty', listing_investigators_path, :title=>'Faculty publications')} </li>
 	<li>#{link_to( 'High Impact', high_impact_by_month_abstracts_path, :title=>'Recent high-impact publications')} </li>
	<li>#{link_to( 'MeSH tag cloud', tag_cloud_abstracts_path, :title=>'Display MeSH tag cloud for all publications')} </li>
	<li>#{link_to( 'Institution Overview', orgs_orgs_path, :title => 'Display an overview of all institutions')} </li>
</ul>
<br style='clear: left' />
</div>"
end
