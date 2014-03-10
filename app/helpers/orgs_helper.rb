module OrgsHelper
  def org_nav_heading
    out = "<span id='nav_links'>"
    if controller.action_name == 'show_investigators' && controller.controller_name == 'orgs'
      out += "<span class='this_page'>Investigators</span>"
    else
      out += link_to('Investigators', show_investigators_org_url(id: params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'show' && controller.controller_name == 'orgs'
      out += "<span class='this_page'>Publications</span>"
    else
      out += link_to('Publications', show_org_url(id: params[:id], page: 1))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'show_org' && controller.controller_name == 'graphs'
      out += "<span class='this_page'>Co-authorship graph</span>"
    else
      out += link_to('Co-authorship graph', show_org_graph_url(params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'show_org' && controller.controller_name == 'graphviz'
      out += "<span class='this_page'>Co-authorship network</span>"
    else
      out += link_to('Co-authorship network', show_org_graphviz_url(params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'show_org_mesh' && controller.controller_name == 'graphviz'
      out += "<span class='this_page'>Similarity network</span>"
    else
      out += link_to('Similarity network', show_org_mesh_graphviz_url(params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'show_org_org' && controller.controller_name == 'graphviz'
      out += "<span class='this_page'>Unit-to-Unit network</span>"
    else
      out += link_to('Unit-to-Unit network', show_org_org_graphviz_url(params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'program_chord' && controller.controller_name == 'cytoscape'
      out += "<span class='this_page'>Chord diagram</span>"
    else
      out += link_to('Chord diagram', program_chord_cytoscape_url(params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'chord' && controller.controller_name == 'cytoscape'
      out += "<span class='this_page'>Unit-to-Unit Chord</span>"
    else
      out += link_to('Unit-to-Unit Chord', chord_cytoscape_index_url)
    end
    out += ' &nbsp;  &nbsp; '
    out += '<br/>Radial Graphs: '
    if controller.action_name == 'show_org' && controller.controller_name == 'cytoscape'
      out += "<span class='this_page'>Publications network</span>"
    else
      out += link_to('Publications network', show_org_cytoscape_url(params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'awards_org' && controller.controller_name == 'cytoscape'
      out += "<span class='this_page'>Funding network</span>"
    else
      out += link_to('Funding network', awards_org_cytoscape_url(params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'org' && controller.controller_name == 'awards'
      out += "<span class='this_page'>Funding report</span>"
    else
      out += link_to('Funding report', org_award_url(id: params[:id], page: 1))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'studies_org' && controller.controller_name == 'cytoscape'
      out += "<span class='this_page'>Studies network</span>"
    else
      out += link_to('Studies network', studies_org_cytoscape_url(params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'org' && controller.controller_name == 'studies'
      out += "<span class='this_page'>Studies report</span>"
    else
      out += link_to('Studies report', org_study_url(id: params[:id], page: 1))
    end
    out += ' &nbsp;  &nbsp; '
    if controller.action_name == 'org_all' && controller.controller_name == 'cytoscape'
      out += "<span class='this_page'>Combined network</span>"
    else
      out += link_to('Combined network', org_all_cytoscape_url(params[:id]))
    end
    out += ' &nbsp;  &nbsp; '
    out += '</span>'
    out.html_safe
  end

  def find_unit_by_id_or_name(val)
    unit = OrganizationalUnit.find_by_abbreviation(val)
    unit = OrganizationalUnit.find_by_name(val) if unit.blank?
    unit = OrganizationalUnit.find_by_search_name(val) if unit.blank?
    unit = OrganizationalUnit.find(val) if unit.blank?
    unit = OrganizationalUnit.find_by_division_id(val) if unit.blank?
    unit
  end

  def get_orgs(id)
    ids = id.split(',')
    if ids.length > 1
      OrganizationalUnit.where('id in (:ids)', { ids: ids }).to_a
    else
      OrganizationalUnit.find_all_by_id(id)
    end
  end
end
