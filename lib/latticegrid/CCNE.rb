
# for cancer centers to 'deselect' publications from inclusion in the CCSG report
def LatticeGridHelper.show_cancer_related_checkbox?
  return true
end

def LatticeGridHelper.page_title
  return 'NU-CCNE Faculty Publications'
end

def LatticeGridHelper.header_title
  return 'CCNE Member Publications and Abstracts Site'
end

def LatticeGridHelper.menu_head_abbreviation
  "CCNE"
end

def LatticeGridHelper.GetDefaultSchool()
  "NU"
end

def LatticeGridHelper.home_url
  "http://nu-ccne.org"
end

def LatticeGridHelper.organization_name
  "Northwestern Center of Cancer Nanotechnology Excellence"
end

def latticegrid_high_impact_description
  "<p>Researchers in the #{LatticeGridHelper.organization_name} publish thousands of articles in peer-reviewed journals every year.  The following recommended reading showcases a selection of their recent work.</p>
  "
end

def LatticeGridHelper.email_subject
  "Contact from the LatticeGrid Publications site at the Northwestern CCNE"
end

def LatticeGridHelper.global_limit_pubmed_search_to_institution?
  false
end

def LatticeGridHelper.include_awards?
  true
end

def LatticeGridHelper.include_studies?
  true
end

def latticegrid_menu_script
"<div id='side_nav_menu' class='ddsmoothmenu-v'>
<ul>
	<li><a href='#'>Publications by year</a>
		#{build_year_menu}
	</li>
	<li><a href='#'>Faculty</a>
		#{build_menu(@head_node.children.sort{|x,y| x.sort_order.to_s.rjust(3,'0')+' '+x.abbreviation <=> y.sort_order.to_s.rjust(3,'0')+' '+y.abbreviation}, Program) {|id| show_investigators_org_path(id)} }
	</li>
	<li><a href='#'>Graphs</a>
		#{build_menu(@head_node.children.sort{|x,y| x.sort_order.to_s.rjust(3,'0')+' '+x.abbreviation <=> y.sort_order.to_s.rjust(3,'0')+' '+y.abbreviation}, Program) {|id| show_org_graph_path(id)} }
	</li>
	<li>#{link_to( 'High Impact', high_impact_by_month_abstracts_path, :title=>'Recent high-impact publications')} </li>
	<li>#{link_to( 'MeSH tag cloud', tag_cloud_abstracts_path, :title=>'Display MeSH tag cloud for all publications')} </li>
	<li>#{link_to( 'Overview', centers_orgs_path, :title => 'Display an overview')}</li>
</ul>
<br style='clear: left' />
</div>"
end

def LatticeGridHelper.affilation_name 
  "Center"
end

def edit_profile_link
  ""
end



