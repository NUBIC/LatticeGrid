def LatticeGridHelper.menu_head_abbreviation
  "Feinberg"
end

def LatticeGridHelper.GetDefaultSchool()
  "Feinberg"
end

def LatticeGridHelper.page_title
  return 'Feinberg Faculty Publications'
end

def LatticeGridHelper.header_title
  return 'Feinberg Publications and Abstracts Site'
end

def LatticeGridHelper.direct_preview_title
   'Northwestern University'
end

def LatticeGridHelper.home_url
  "http://www.feinberg.northwestern.edu"
end

def LatticeGridHelper.curl_host
	my_env = Rails.env
	my_env = 'home' if public_path =~ /Users/ 
	case 
	  when my_env == 'home': 'localhost:3000'
	  when my_env == 'development': 'rails-staging2.nubic.northwestern.edu'
	  when my_env == 'staging': 'rails-staging2.nubic.northwestern.edu'
	  when my_env == 'production': 'latticegrid.feinberg.northwestern.edu'
	  else 'rails-dev.bioinformatics.northwestern.edu/fsm_pubs'
	end 
end

def LatticeGridHelper.curl_protocol
	my_env = Rails.env
	my_env = 'home' if public_path =~ /Users/ 
	case 
	  when my_env == 'home': 'http'
	  when my_env == 'development': 'http'
	  when my_env == 'staging': 'http'
	  when my_env == 'production': 'http'
	  else 'http'
	end 
end

def LatticeGridHelper.include_awards?
  true
end

def edit_profile_link
  link_to("Edit your FSM profile", "https://fsmweb.northwestern.edu/facultylogin/", :title=>"Login with your NetID and NetID password to change your profile and publication record")
end

def menu_script
  
"<div id='side_nav_menu' class='ddsmoothmenu-v'>
<ul>
	<li><a href='#'>Publications by year</a>
		#{build_year_menu}
	</li>
	<li><a href='#'>Publications by department</a>
		#{build_menu(@head_node.children, Department) {|id| org_path(id)}}
	</li>
	<li><a href='#'>Faculty by department</a>
		#{build_menu(@head_node.children, Department) {|id| show_investigators_org_path(id)}}
	</li>
	<li><a href='#'>Graphs by department</a>
		#{build_menu(@head_node.children, Department) {|id| show_org_graph_path(id)}}
	</li>
	<li><a href='#'>Center publications</a>
		#{build_menu(@head_node.children, Center) {|id| org_path(id)}}
	</li>
	<li><a href='#'>Center members</a>
		#{build_menu(@head_node.children, Center) {|id| show_investigators_org_path(id)}}
	</li>
	<li><a href='#'>Center graphs</a>
		#{build_menu(@head_node.children, Center) {|id| show_org_graph_path(id)}}
	</li>
	<li>#{link_to( 'MeSH tag cloud', tag_cloud_abstracts_path, :title=>'Display MeSH tag cloud for all publications')} </li>
	<li>#{link_to( 'Department Overview', departments_orgs_path, :title => 'Display an overview of all departments')} </li>
	<li>#{link_to( 'Center Overview', centers_orgs_path, :title => 'Display an overview for all centers')}</li>
</ul>
<br style='clear: left' />
</div>"
end
