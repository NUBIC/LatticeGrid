
# for cancer centers to 'deselect' publications from inclusion in the CCSG report
def LatticeGridHelper.show_cancer_related_checkbox?
  true
end

def LatticeGridHelper.page_title
  'NU-CCNE Faculty Publications'
end

def LatticeGridHelper.header_title
  'CCNE Member Publications and Abstracts Site'
end

def LatticeGridHelper.menu_head_abbreviation
  'CCNE'
end

def LatticeGridHelper.get_default_school
  'NU'
end

def LatticeGridHelper.home_url
  'http://nu-ccne.org'
end

def LatticeGridHelper.organization_name
  'Northwestern Center of Cancer Nanotechnology Excellence'
end

def latticegrid_high_impact_description
  %Q(<p>
       Researchers in the #{LatticeGridHelper.organization_name} publish thousands of articles in peer-reviewed journals every year.
       The following recommended reading showcases a selection of their recent work.
     </p>)
end

def LatticeGridHelper.email_subject
  'Contact from the LatticeGrid Publications site at the Northwestern CCNE'
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
  menu = %Q(
    <div id='side_nav_menu' class='ddsmoothmenu-v'>
      <ul>
        <li>
          <a href='#'>Publications by year</a>
          #{build_year_menu}
        </li>
        <li>
          #{link_to('Faculty', show_investigators_org_path(@head_node.children.first.id), :title => 'List of Faculty')}
        </li>
        <li>
          #{link_to('Graphs', show_org_graph_path(@head_node.children.first.id), :title => 'Graph of interactions')}
        </li>
        <li>
          #{link_to('High Impact', high_impact_by_month_abstracts_path, :title => 'Recent high-impact publications')}
        </li>
        <li>
          #{link_to('MeSH tag cloud', tag_cloud_abstracts_path, :title => 'Display MeSH tag cloud for all publications')}
        </li>
        <li>
          #{link_to('Bundle Graph', investigator_edge_bundling_cytoscape_path, :title => 'Display Hierarchical Edge Bundle graph for all investigators')}
        </li>
        <li>
          #{link_to('Overview', centers_orgs_path, :title => 'Display an overview')}
        </li>
      </ul>
      <br style='clear: left' />
    </div>)
  menu
end

def LatticeGridHelper.affilation_name
  'Center'
end

def edit_profile_link
  ''
end
