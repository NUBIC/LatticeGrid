def LatticeGridHelper.menu_head_abbreviation
  "Feinberg"
end

def LatticeGridHelper.high_impact_issns
  ["0028-4793", "0732-0582", "1471-0072", "1474-175X", "1061-4036", "0028-0836", "1474-1733", "0140-6736", "1471-0056", "0092-8674", "0036-8075", "1087-0156", "1748-3387", "0098-7484", "1476-1122", "0066-4154", "1471-0048", "1474-1776", "0031-9333", "1535-6108", "0147-006X", "1934-5909", "1529-2908", "1078-8956", "1074-7613", "0140-525X", "0066-4197", "1474-4422", "1548-7091", "1740-1526", "1465-7392", "1550-4131", "1755-4330", "1470-2045", "0003-4819", "1473-3099", "0066-4278", "1552-4450", "1549-1277", "1359-4184", "0022-1007", "0009-7322", "1097-2765", "1097-6256", "0021-9738", "1081-0706", "0896-6273", "1534-5807", "1545-9985", "0955-0674", "0959-535X", "1674-2788", "0890-9369", "1544-9173", "0066-4219"]
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
   ''
end

def LatticeGridHelper.home_url
  "http://www.feinberg.northwestern.edu"
end

def LatticeGridHelper.organization_name
  "Feinberg School of Medicine"
end

def latticegrid_high_impact_description
  '<p>' + image_tag("#{lattice_grid_instance}/high_impact_research.jpg", options={:alt=>"high impact research", :height => "180", :width => "637"}) + '</p>
  <p>Researchers in the ' + LatticeGridHelper.organization_name + ' publish thousands of articles in peer-reviewed journals every year.  The following recommended reading showcases a selection of their recent work.</p>'
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

def LatticeGridHelper.include_studies?
  true
end

def edit_profile_link
  link_to("Edit your FSM profile", "https://fsmweb.northwestern.edu/facultylogin/", :title=>"Login with your NetID and NetID password to change your profile and publication record")
end

def latticegrid_menu_script
  
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
 	<li>#{link_to( 'High Impact', high_impact_by_month_abstracts_path, :title=>'Recent high-impact publications')} </li>
	<li>#{link_to( 'MeSH tag cloud', tag_cloud_abstracts_path, :title=>'Display MeSH tag cloud for all publications')} </li>
	<li>#{link_to( 'Department Overview', departments_orgs_path, :title => 'Display an overview of all departments')} </li>
	<li>#{link_to( 'Center Overview', centers_orgs_path, :title => 'Display an overview for all centers')}</li>
</ul>
<br style='clear: left' />
</div>"
end
