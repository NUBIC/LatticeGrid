# -*- coding: utf-8 -*-

require 'publication_utilities'
require 'link_helper'

##
# LatticeGridHelper module default values for all
# LatticeGrid instances. Values can be overridden in files
# located in the #{Rails.root}/lib/latticegrid/ directory which
# are named the same as the LatticeGrid.the_instance value in
# #{Rails.root}/config/application.rb
module LatticeGridHelper
  # class methods
  def self.version
    '2.0.2'
  end

  def self.page_title
    'LatticeGrid Publications'
  end

  def self.header_title
    "LatticeGrid Publications and Abstracts Site<div id='subtitle'>An open source publications/collaboration assessment tool</div>"
  end

  def self.direct_preview_title
    'LatticeGrid Publications'
  end

  # does the application require authentication?
  def self.require_authentication?
    false
  end

  # support editing investigator profiles? Implies that authentication is supported!
  def self.allow_profile_edits?
    false
  end

  # allowed membership types
  def self.allowed_membership_types
    ['Member']
  end

  def self.include_org_type(org)
    org.type == 'Program'
  end

  def self.include_summary_by_member?
    true
  end

  def self.include_research_summary_by_organization?
    false
  end

  # for cancer centers to 'deselect' publications from inclusion in the CCSG report
  def self.show_cancer_related_checkbox?
    false
  end

  # show research description
  def self.show_research_description?
    true
  end

  def self.menu_head_abbreviation
    'Lurie Cancer Center'
  end

  def self.logs_after
    '10/1/2011'
  end

  def self.high_impact_issns
    []
  end

  def self.get_default_school
    'Feinberg'
  end

  def self.cache_pages?
    true
  end

  def self.google_analytics
    ''
  end

  def self.curl_host
    my_env = Rails.env
    my_env = 'home' if public_path =~ /Users/
    case my_env
    when 'home'
      'localhost:3000'
    when 'development', 'staging'
      'rails-staging2.nubic.northwestern.edu'
    when 'production'
      'latticegrid.cancer.northwestern.edu'
    else
      'rails-dev.bioinformatics.northwestern.edu/cancer'
    end
  end

  def self.curl_protocol
    my_env = Rails.env
    my_env = 'home' if public_path =~ /Users/
    case my_env
    when 'home'
      'http'
    when 'development', 'staging', 'production'
      'https'
    else
      'http'
    end
  end

  def self.year_array
    return @@year_array if defined?(@@year_array)
    starting_year = Time.now.year
    @@year_array = (starting_year-9 .. starting_year).to_a
    @@year_array.reverse!
    @@year_array
  end

  def self.email_subject
    'Contact from the LatticeGrid Publications site'
  end

  def self.home_url
    # 'http://www.cancer.northwestern.edu'
    'http://wiki.bioinformatics.northwestern.edu/index.php/LatticeGrid'
  end

  def self.organization_name
    'institution'
  end

  def latticegrid_high_impact_description
    '<p>Researchers at our institution publish thousands of articles in peer-reviewed journals every year.  ' +
    'The following recommended reading showcases a selection of their recent work.</p>'
  end

  def self.cleanup_campus(pi)
   # clean up the campus data
   pi.campus = pi.campus =~ /CH|Chicago/ ? 'Chicago' : pi.campus
   pi.campus = pi.campus =~ /EV|Evanston/ ? 'Evanston' : pi.campus
   pi.campus = pi.campus =~ /CMH|Children/ ? 'CMH' : pi.campus
   pi
  end

  def self.do_ajax?
    # (is_admin? && Rails.env != 'production') ? false : true
    true
  end

  def self.do_ldap?
    # (is_admin? && Rails.env != 'production') ? false : true
    true
  end

  def self.ldap_perform_search?
    true
  end

  def self.ldap_host
    'directory.northwestern.edu'
  end

  def self.ldap_treebase
    'ou=People, dc=northwestern,dc=edu'
  end

  def self.include_awards?
    false
  end

  def self.include_studies?
    false
  end

  def self.allowed_ips
    # childrens: 199.125.
    # nmff: 209.107.
    # nmh: 165.20.
    # enh: 204.26
    # ric: 69.216
    [':1','127.0.0.*','165.124.*','129.105.*','199.125.*','209.107.*','165.20.*','204.26.*','69.216.*']
  end

  def self.set_investigator_class(citation, investigator, is_member = false)
    if is_member
      if is_last_author?(citation, investigator)
        'member_last_author'
      elsif is_first_author?(citation, investigator)
        'member_first_author'
      else
        'member_author'
      end
    else
      if is_last_author?(citation, investigator)
        'last_author'
      elsif is_first_author?(citation, investigator)
        'first_author'
      else
        'author'
      end
    end
  end

  def self.member_types_map
   {
     'Member' => Member,
     'Associate' => AssociateMember,
     'Full' => Member
   }
  end

  # LatticeGrid prefs:
  # turn on lots of output
  def self.debug?
    false
  end

  # try multiple searches if a search returns too many or too few publications
  def self.smart_filters?
    true
  end

  def self.mark_full_name_searches_as_valid?
    false
  end

  # print timing and completion information
  def self.verbose?
    true
  end

  # limit searches to include the institutional_limit_search_string
  def self.global_limit_pubmed_search_to_institution?
    true
  end

  # use full first name in PubMed searches
  def self.global_pubmed_search_full_first_name?
    true
  end

  def self.build_institution_search_string_from_department?
    false
  end

  def self.affilation_name
    'Department'
  end

  # build self.institutional_limit_search_string to identify all the publications at your institution

  def self.institutional_limit_search_string
    '( "Northwestern University"[affil] OR "Feinberg School"[affil] OR "Robert H. Lurie Comprehensive Cancer Center"[affil] OR "Northwestern Healthcare"[affil] OR "Children''s Memorial"[affil] OR "Northwestern Memorial"[affil] OR "Northwestern Medical"[affil])'
  end

  # these names will always be limited to the institutional search only even if LatticeGridHelper.global_limit_pubmed_search_to_institution?` is false
  def self.last_names_to_limit
    %w(Brown Chen Das Khan Li Liu Lu Lee Shen Smith Tu Wang Xia Yang Zhou)
  end

  # these are for messages regarding the expected number of publications
  def self.expected_min_pubs_per_year
    1
  end

  def self.expected_max_pubs_per_year
    30
  end

  # you shouldn't need to change these ...
  def self.all_years
    10
  end

  def self.default_number_years
    1
  end

  def self.default_fill_color
    '#A28BA9'
  end

  def self.white_fill_color
    '#FFFFFF'
  end

  def self.root_fill_color
    '#FFAD33'
  end

  def self.root_other_fill_color
    '#E8A820'
  end

  # pale gold
  def self.first_degree_fill_color
    '#FFE0C2'
  end

  # pale violet grey - E6E0E8
  # pale avacado greeen
  def self.first_degree_other_fill_color
    '#CAD4B8'
  end

  # pale gold - FFE9BF
  def self.second_degree_fill_color
    '#FFFFCC'
  end

  # pale blue green
  def self.second_degree_other_fill_color
    '#A3DADA'
  end

  # super pale green
  def self.second_degree_other_fill_color
    '#CCF5CC'
  end

  # must be instance methods, not class methods

  # profile example summaries
  def profile_example_summaries
    ''
  end

  # citation style
  def format_citation(publication, link_abstract_to_pubmed=false, mark_members_bold=false, investigators_in_unit=[], speed_display=false, simple_links=false)
    #  out = publication.authors
    if mark_members_bold
      out = highlight_member_investigator(publication, speed_display, simple_links, investigators_in_unit)
    else
      out = highlight_investigator(publication, speed_display, simple_links)
    end
    out << ' '
    if link_abstract_to_pubmed
      out << link_to(publication.title, "http://www.ncbi.nlm.nih.gov/pubmed/#{publication.pubmed}", target: '_blank', title: 'PubMed ID')
    else
      out << link_to(publication.title, abstract_url(publication))
    end
    out << journal_volume_and_pages(publication)
    out << [quicklink_to_pubmed(publication.pubmed), quicklink_to_pubmedcentral(publication.pubmedcentral), quicklink_to_doi(publication.doi)].compact.join('; ')
  end

  def journal_volume_and_pages(publication, use_abbr = true)
    abbr = use_abbr ? publication.journal_abbreviation : publication.journal
    out = ''
    out << "<i>#{abbr}</i> "
    out << " (#{publication.year}) "
    if publication.pages.try(:length).to_i > 0
      out << "#{h(publication.volume)}:#{h(publication.pages)}. "
    else
      out << '<i>In process.</i> '
    end
    out
  end

  def link_to_investigator(citation, investigator, name = nil, is_member = false, speed_display = false, simple_links = false, class_name = nil)
    name = investigator.last_name if name.blank?
    link_to(name,
            show_investigator_url(id: investigator.username, page: 1), # can't use this form for usernames including non-ascii characters
            class: investigator_class(class_name, speed_display, citation, investigator, is_member),
            title: investigator_title(simple_links, investigator))
  end

  def investigator_class(class_name, speed_display, citation, investigator, is_member)
    result = class_name
    if result.blank?
      if speed_display
        result = 'author'
      else
        result = LatticeGridHelper.set_investigator_class(citation, investigator, is_member)
      end
    end
    result
  end

  def investigator_title(simple_links, investigator)
    if simple_links
      "Go to #{investigator.full_name}: #{investigator.total_publications} pubs"
    else
      "Go to #{investigator.full_name}: #{investigator.total_publications} pubs, " +
      (investigator.num_intraunit_collaborators + investigator.num_extraunit_collaborators).to_s +
      ' collaborators'
    end
  end

  # investigator highlighting
  def highlight_member_investigator(citation, speed_display = false, simple_links = false, member_array = nil)
    if member_array.blank?
      authors = highlight_investigator(citation, speed_display, simple_links)
    else
      authors = highlight_investigator(citation, speed_display, simple_links, citation.authors, member_array)
    end
    authors
  end

  def highlight_investigator(citation, speed_display = false, simple_links = false, authors = nil, member_array = nil)
    authors = citation.authors if authors.blank?
    citation.investigators.each do |investigator|
      re = Regexp.new('(' + investigator.last_name.downcase + ', ' + investigator.first_name.at(0).downcase + '[^;\n]*)', Regexp::IGNORECASE)
      is_member = (!member_array.blank? && member_array.include?(investigator.id))
      authors.gsub!(re) do |author_match|
        link_to_investigator(citation, investigator, author_match.gsub(' ', '| '), is_member, speed_display, simple_links)
      end
    end
    authors = authors.to_s.gsub('|', '')
    authors = authors.to_s.gsub("\n", '; ')
    authors
  end

  def edit_profile_link
    link_to('Edit profile',
            profiles_path,
            title: 'Login with your NetID and NetID password to change your profile')
  end

  def latticegrid_menu_script
    menu = %Q(
      <div id='side_nav_menu' class='ddsmoothmenu-v'>
        <ul>
          <li>
            <a href='#'>Publications by year</a>
            #{build_year_menu}
          </li>
          #{latticegrid_menu_script_head_node_children(@head_node)}
          <li>
            #{link_to('High Impact', high_impact_by_month_abstracts_path, title: 'Recent high-impact publications')}
          </li>
          <li>
            #{link_to('MeSH tag cloud', tag_cloud_abstracts_path, title: 'Display MeSH tag cloud for all publications')}
          </li>
          <li>
            #{link_to('Bundle Graph', investigator_edge_bundling_cytoscape_index_path, title: 'Display Hierarchical Edge Bundle graph for all investigators')}
          </li>
          <li>
            #{link_to('Chord Graph', chord_cytoscape_index_path, title: 'Display Chord graph for all investigators')}
          </li>
          <li>
            #{link_to('Overview', programs_orgs_path, title: 'Display an overview for all programs')}
          </li>
        </ul>
        <br style='clear: left' />
      </div>
    )
    menu
  end

  def latticegrid_menu_script_head_node_children(head_node)
    return '' unless head_node.try(:children)

    pub_menu     = build_menu(sorted_head_node_children(head_node), Program) { |id| org_path(id) }
    faculty_menu = build_menu(sorted_head_node_children(head_node), Program) { |id| show_investigators_org_path(id) }
    graph_menu   = build_menu(sorted_head_node_children(head_node), Program) { |id| show_org_graph_path(id) }

    menu = ''
    menu << sub_menu_line_item('Publications by program', pub_menu)
    menu << sub_menu_line_item('Faculty by program', faculty_menu)
    menu << sub_menu_line_item('Graphs by program', graph_menu)
    menu
  end

  def sub_menu_line_item(txt, menu)
    return '' if menu.blank? || menu == '<ul></ul>'
    menu = "<li><a href='#'>#{txt}</a>#{menu}</li>"
    menu
  end

  def sorted_head_node_children(head_node)
    head_node.children.sort do |x, y|
      x.sort_order.to_s.rjust(3, '0') + ' ' + x.abbreviation <=> y.sort_order.to_s.rjust(3, '0') + ' ' + y.abbreviation
    end
  end

  def build_menu(nodes, org_type = nil, &block)
    return '' if nodes.blank?
    out = '<ul>'
    nodes.each do |unit|
      if org_type.nil? || unit.kind_of?(org_type)
        out += '<li>'
        out += link_to(truncate(unit.name.gsub(/\'/, ''), length: 80), yield(unit.id))
        out += build_menu(unit.children, nil, &block) unless unit.leaf?
        out += '</li>'
      end
    end
    out += '</ul>'
    out
  end

  def build_year_menu
    out = '<ul>'
    LatticeGridHelper.year_array.each do |the_year|
      if !controller.action_name.match('year_list').nil? && the_year.to_s == @year
        out += "<li class='current'>"
      else
        out += '<li>'
      end
      out += link_to(the_year, abstracts_by_year_url(id: the_year, page: 1))
      out += '</li>'
    end
    out += '</ul>'
    out
  end

  def is_admin?
    begin
      return true unless LatticeGridHelper.require_authentication?
      return true if %w(wakibbe admin tvo743 jkk366 jhl197 ddc830 mar352 vvs359 pfr957).include?(current_user.username.to_s)
    rescue
      begin
        logger.error "is_admin? threw an error on include?(current_user.username.to_s) [#{current_user.username}]"
      rescue
        puts "is_admin? threw an error on include?(current_user.username.to_s) [#{current_user.username}]"
      end
    end
    false
  end

end
