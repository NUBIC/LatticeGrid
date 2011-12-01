module OrgsHelper
  def org_nav_heading()
    out="<span id='nav_links'>"
    if not (controller.action_name == 'show_investigators' and controller.controller_name == 'orgs')
      out+= link_to('Investigators', show_investigators_org_url(:id=>params[:id]) ) 
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show' and controller.controller_name == 'orgs')
      out+= link_to('Publications', show_org_url(:id=>params[:id], :page=>1) ) 
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show_org' and controller.controller_name == 'graphs')
      out+= link_to('Co-authorship graph', show_org_graph_url(params[:id]) ) 
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show_org' and controller.controller_name == 'graphviz')
      out+= link_to( "Co-authorship network", show_org_graphviz_url(params[:id]) )
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show_org' and controller.controller_name == 'cytoscape')
      out+= link_to( "Cytoscape network", show_org_cytoscape_url(params[:id]) )
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show_org_mesh' and controller.controller_name == 'graphviz')
      out+= link_to( "MeSH similarities network", show_org_mesh_graphviz_url(params[:id]))
      out+= " &nbsp;  &nbsp; "  
    end
    if not (controller.action_name == 'show_org_org' and controller.controller_name == 'graphviz')
      out+= link_to( "Unit-to-Unit co-authorship network", show_org_org_graphviz_url(params[:id]))
      out+= " &nbsp;  &nbsp; "  
    end
    out+"</span>"
  end
  
  def find_unit_by_id_or_name(val)
    unit = OrganizationalUnit.find_by_abbreviation(val)
    if unit.blank?
      unit = OrganizationalUnit.find_by_name(val)
    end
    if unit.blank?
      unit = OrganizationalUnit.find_by_search_name(val)
    end
    if unit.blank?
      unit = OrganizationalUnit.find_by_id(val)
    end
    if unit.blank?
      unit = OrganizationalUnit.find_by_division_id(val)
    end
    unit
  end
end