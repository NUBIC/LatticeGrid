# -*- coding: utf-8 -*-
#
# Controller for OrganizationalUnit model
class OrgsController < ApplicationController
  caches_page(:show, :index, :departments, :centers, :programs, :show_investigators, :stats, :full_show, :tag_cloud, :short_tag_cloud, :barchart) if LatticeGridHelper.CachePages

  skip_before_filter  :find_last_load_date, :only => [:barchart]
  skip_before_filter  :handle_year, :only => [:barchart]
  skip_before_filter  :get_organizations, :only => [ :barchart]
  skip_before_filter  :handle_pagination, :only => [:barchart]
  skip_before_filter  :define_keywords, :only => [:barchart]

  helper :sparklines
  include ApplicationHelper
  include OrgsHelper
  include SparklinesHelper

  if RUBY_VERSION =~ /1.9/
    require 'csv'
  else
    require 'fastercsv'
  end

  # GET /orgs
  # GET /orgs.xml
  def index
    @units = OrganizationalUnit.includes([:members,:organization_abstracts, :primary_faculty, :joint_faculty, :secondary_faculty])
                               .order('sort_order, lower(abbreviation)').to_a
    @heading = "Current Org Listing"
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @units }
    end
  end

  def department_collaborations
    year = 2006
    edge_strength_to_graph = 10
    @units = OrganizationalUnit.collaborations("9/1/#{year-1}","9/1/#{year}")
    @heading = "Departmental Collaborations for FY#{year}"
    respond_to do |format|
      format.html { render(:layout => 'scaled') }
      format.xml  { render :xml => @units }
      format.csv do
        unit_ids = @units.collect(&:id)
        if RUBY_VERSION =~ /1.9/
          csv_string = CSV.generate do |csv|
            # header row
            csv << [ "id", "name", "investigators", "total", "units" ] + @units.collect(&:name)

            # data rows
            @units.each do |unit|
              total_units =  unit_ids.collect{|unit_id| (unit_id == unit.id) ? 0 : unit.collaboration_matrix[unit_id].length }.sum
              csv << [unit.id, unit.name, unit.primary_faculty.length, unit.collaboration_matrix[unit.id].length, total_units ] + unit_ids.collect { |unit_id| (unit_id == unit.id) ? 0 : unit.collaboration_matrix[unit_id].length }
            end
          end
        else
          csv_string = FasterCSV.generate do |csv|
            # header row
            csv << [ "id", "name", "investigators", "total", "units" ] + @units.collect(&:name)

            # data rows
            @units.each do |unit|
              total_units =  unit_ids.collect{|unit_id| (unit_id == unit.id) ? 0 : unit.collaboration_matrix[unit_id].length }.sum
              csv << [unit.id, unit.name, unit.primary_faculty.length, unit.collaboration_matrix[unit.id].length, total_units ] + unit_ids.collect {|unit_id| (unit_id == unit.id) ? 0 : unit.collaboration_matrix[unit_id].length }
            end
          end
        end

        # send it to the browser
        send_data csv_string,
                  :type => 'text/csv; charset=iso-8859-1; header=present',
                  :disposition => "attachment; filename=department_collaborations.csv"
      end

      format.dot do
        unit_ids   = @units.collect(&:id)
        # format
        dot_string = "graph G {\r"
        dot_string << "graph [fontname=Arial,fontsize=24, label=\"\\n#{@heading}\"];\r"
        dot_string << "nodesep=0.5; mindist=1.0; clusterrank=global; rankdir=LR;\r"
        dot_string << "node [style=filled,color=gray,fontname=Arial,fontsize=16];\r"
        dot_string << "edge [color=gray,fontname=Arial,fontsize=16];\r"

        # precalculate
        cnt = 0 # start at zero or if you want to break this into shorter tasks, you could break it differently
        last = @units.length-1
        to_process = last-cnt
        nodes = []
        max_length = 0
        max_units = 0
        @units[cnt..last].each do |outer_unit|
          cnt += 1
          total_units = unit_ids.collect{ |unit_id| (unit_id == outer_unit.id) ? 0 : outer_unit.collaboration_matrix[unit_id].length }.sum
          max_units = total_units if max_units < total_units
          @units[cnt..last].each do |inner_unit|
            if outer_unit.collaboration_matrix[inner_unit.id].length > edge_strength_to_graph
              nodes << inner_unit.id
              nodes << outer_unit.id
              max_length = outer_unit.collaboration_matrix[inner_unit.id].length if max_length < outer_unit.collaboration_matrix[inner_unit.id].length
            end
          end
        end
        nodes = nodes.sort.uniq
        # output the nodes
        @units.each { |unit| dot_string << ' node'+unit.id.to_s+' [label="'+unit.name+'" color='+node_color(unit_ids.collect{|unit_id| (unit_id == unit.id) ? 0 : unit.collaboration_matrix[unit_id].length }.sum,max_units)+']'+";\r" if nodes.include?(unit.id) }
        #create the edges
        cnt = 0 # start at zero or if you want to break this into shorter tasks, you could break it differently
        last = @units.length-1
        to_process = last-cnt
        @units[cnt..last].each do |outer_unit|
          cnt+=1
          @units[cnt..last].each do |inner_unit|
             if outer_unit.collaboration_matrix[inner_unit.id].length > edge_strength_to_graph
              pubs = outer_unit.collaboration_matrix[inner_unit.id].length
              the_length = (10-(pubs/(max_length/9))).to_i
              dot_string << ' node'+outer_unit.id.to_s+' -- node'+inner_unit.id.to_s+' [len='+the_length.to_s+' color='+color_scheme(the_length)+' label="'+pubs.to_s+' pubs"]'+";\r"
            end
          end
        end

        # complete the graph
        dot_string << "}\r"

        # send it to the browser
        send_data dot_string,
                  :type => 'text/plain; charset=iso-8859-1; header=present',
                  :disposition => "attachment; filename=department_collaborations.dot"
      end
    end
  end

  def color_scheme(color_number)
    case color_number
    when 0..2 then "maroon"
    when 3..4 then "firebrick"
    when 5..6 then "darkturquoise"
    when 7..8 then "slategray"
    when 9 then "powderblue"
    else "goldenrod"
    end
  end

  def node_color(pub_units, max_units)
    case (5-(pub_units/(max_units/5))).to_i
    when 0 then "tomato"
    when 1 then "coral"
    when 2 then "thistle"
    when 3 then "cyan"
    when 4 then "powderblue"
    else "lightgray"
    end
  end

  def orgs
    @units = OrganizationalUnit.includes([:members, :organization_abstracts, :primary_faculty, :joint_faculty, :secondary_faculty])
                               .order('sort_order, lower(abbreviation)').to_a
    @heading = "Current #{LatticeGridHelper.affilation_name} Listing"
    if LatticeGridHelper.affilation_name != "Department"
      @show_associated_faculty = false
      @show_members = false
      @show_unit_type = false
    end
    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @units }
    end
  end

  def departments
    @units = Department.includes([:members, :organization_abstracts, :primary_faculty, :joint_faculty, :secondary_faculty])
                       .order('sort_order, lower(abbreviation)').to_a
    @heading = "Current #{LatticeGridHelper.affilation_name} Listing"
    if LatticeGridHelper.affilation_name != "Department"
      @show_associated_faculty = false
      @show_members = false
      @show_unit_type = false
    end
    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @units }
    end
  end

  def centers
    @units = Center.includes([:members, :organization_abstracts, :primary_faculty, :joint_faculty, :secondary_faculty])
                   .order('sort_order, lower(abbreviation)').to_a
    @heading = "Current Center Listing"
    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @units }
    end
  end

  def classifications
    @classifications = Program.select('organization_classification').group('organization_classification')
    cats = @classifications.map(&:organization_classification)
    respond_to do |format|
      format.html { render :text=> cats.inspect }
      format.js { render :json => {"classifications" => cats }.as_json }
    end
  end

  def classification_orgs
    @units = Program.select('name, abbreviation, division_id, id, organization_classification')
                    .where('organization_classification = :organization_classification', { :organization_classification => params[:id] })
                    .order('sort_order, lower(abbreviation)').to_a
    respond_to do |format|
      format.html { render :text=> @units.inspect }
      format.js { render :json => {"orgs" => @units }.as_json() }
    end
  end

  def programs
    @units = Program.includes([:members,:organization_abstracts, :primary_faculty, :joint_faculty, :secondary_faculty])
                    .order('sort_order, lower(abbreviation)').to_a
    @heading = "Center Programs Listing"
    associate_members = AssociateMember.count
    @show_primary_faculty = false
    @show_associated_faculty = false
    @show_associate_members = true if associate_members > 0
    @show_unit_type = false
    program_array = @units.collect do |unit|
      { "unit_name" => unit.name, "abbreviation" => unit.abbreviation, "id" => unit.id }
    end
    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @units }
      format.js { render :json => {:programs => program_array }.as_json }
    end
  end

  def program_members
    @unit = find_unit_by_id_or_name(params[:id])
    if @unit.blank?
      render :text=>'could not find unit ' + params[:id]
    else
      investigators = @unit.all_associated_faculty
      investigators_array = investigators.collect do |inv|
        { "username" => inv.username, "name" => inv.full_name, "department" => inv.home_department_name, "title" => inv.title }
      end
      respond_to do |format|
        format.html { render :text => @unit.name }
        format.js { render :json => { "unit_name" => @unit.name, :faculty => investigators_array }.as_json }
      end
    end
  end

  def show_investigators
    if params[:id].nil?
      redirect_to index_orgs_url
    else
      @unit = find_unit_by_id_or_name(params[:id])
      @heading = "Faculty Listing for '#{@unit.name}'"

      respond_to do |format|
        format.html # show_investigators.html.erb
        format.xml  { render xml: @unit }
        format.pdf do
          @pdf = true
          render pdf: "Show Investigators for #{@unit.name}",
                 stylesheets: ['pdf'],
                 template: 'orgs/show_investigators.html.erb',
                 layout: 'pdf'
        end
      end
    end
  end

  # GET /orgs/1
  # GET /orgs/1.xml
  def show
    redirect = false
    if params[:page].nil?
      params[:page] = '1'
      redirect = true
    end
    if params[:id].nil?
      redirect_to index_orgs_url
    elsif redirect then
      # FIXME: redirect_to params does not work in Rails 3
      redirect_to params
    else
      @unit = find_unit_by_id_or_name(params[:id])
      @do_pagination = '1'
      @abstracts = @unit.abstract_data( params[:page] )
      @all_abstracts = @unit.get_minimal_all_data
      @heading = "Publications (total of #{@abstracts.total_entries})"

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @abstracts }
      end
    end
  end

  def full_show
    redirect = false
    if params[:id].nil? then
      redirect_to index_orgs_url
    elsif !params[:page].nil? then
      params.delete(:page)
      # FIXME: redirect_to params does not work in Rails 3
      redirect_to params
    else
      @unit = find_unit_by_id_or_name(params[:id])
      @do_pagination = '0'
      @abstracts = @unit.display_year_data(@year)
      @all_abstracts = @unit.get_minimal_all_data
      @heading = "Publications during #{@year} (total of #{@abstracts.length})"
      render :action => 'show'
    end
  end

  def barchart
    @unit = find_unit_by_id_or_name(params[:id])
    publications_per_year=abstracts_per_year_as_string(@unit.abstracts)

    respond_to do |format|
      format.js { render :layout => false, :js => jquery_sparkline_barchart('barchart_'+@unit.id.to_s, publications_per_year) }
    end
  end

  # get all publications by members
  # then get the number of intra-unit collaborations and the number of inter-unit collaborations
  def period_stats
    handle_start_and_end_date
    @heading = "Publication Statistics by Program from #{params[:start_date]} to #{params[:end_date]} "
    @units = build_stats_array
    render :layout => 'printable', :action => 'stats'
  end

  # get all publications by  members
  # then get the number of intra-unit collaborations and the number of inter-unit collaborations
  def stats
    params[:start_date] = 5.years.ago
    params[:end_date] = Date.tomorrow
    handle_start_and_end_date
    @heading = 'Publication Statistics by Program for the past five years'
    @units = build_stats_array
    render :layout => 'printable'
  end

  def tag_cloud
    org = OrganizationalUnit.find(params[:id])
    tags = org.abstracts.tag_counts(:limit => 150, :order => "count desc", :at_least => 10)
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags, :org => org}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags, :org => org} }
    end
  end

  def short_tag_cloud
    investigator = Investigator.find(params[:id])
    tags = investigator.abstracts.tag_counts(:limit => 7, :order => "count desc")
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => { :tags => tags, :investigator => investigator } }
      format.js  { render  :partial => "shared/tag_cloud", :locals => { :tags => tags, :investigator => investigator, :update_id => "short_tag_cloud_#{investigator.id}" } }
    end
  end

  # these are not cached

  def list
    handle_start_and_end_date
    @heading = 'Publication Listing by Org '
    @heading = "#{@heading} for #{@year} " if params[:start_date].blank?
    @heading = "#{@heading} from #{@start_date} " unless params[:start_date].blank?
    @heading = "#{@heading} to #{@end_date}" unless params[:end_date].blank?
    render layout: 'printable'
  end

  def list_abstracts_during_period_rjs
    handle_start_and_end_date
    @unit = OrganizationalUnit.find(params[:id])
    @faculty = @unit.get_faculty_by_types(params[:affiliation_types])
    @exclude_letters = !params[:exclude_letters].blank?
    @faculty_affiliation_types = params[:affiliation_types]
    faculty_ids = @faculty.map(&:id)
    @abstracts = Abstract.all_ccsg_publications_by_date(faculty_ids, params[:start_date], params[:end_date], @exclude_letters)
  end

  def abstracts_during_period
    # for printing
    handle_start_and_end_date
    @unit = OrganizationalUnit.find(params[:id])
    @faculty_affiliation_types = params[:affiliation_types]
    @faculty = @unit.get_faculty_by_types(params[:affiliation_types])
    @exclude_letters = !params[:exclude_letters].blank?
    @limit_to_first_last = !params[:limit_to_first_last].blank?
    @impact_factor = params[:impact_factor]
    @investigators_in_unit = @faculty.map(&:id)

    @abstracts = Abstract.all_ccsg_publications_by_date(@investigators_in_unit, params[:start_date], params[:end_date], @exclude_letters, @limit_to_first_last, @impact_factor)

    @do_pagination = '0'
    @heading = "#{@abstracts.length} publications. Publication Listing"
    @heading = "#{@heading} excluding letters" if @exclude_letters
    @heading = "#{@heading} with at least an impact factor of #{@impact_factor}" unless @impact_factor.blank?
    @heading = "#{@heading} from #{@start_date} " unless params[:start_date].blank?
    @heading = "#{@heading} to #{@end_date}" unless params[:end_date].blank?
    @heading = "#{@heading} limited to first and last authors who are part of #{@unit.name}" if @limit_to_first_last
    @include_mesh = false
    @include_graph_link = false
    @show_paginator = false
    @include_investigators = true
    @include_pubmed_id = true
    @include_collab_marker = true
    @bold_members = true
    @include_impact_factor = true
    @simple_links = true

    respond_to do |format|
      format.html { render layout: 'printable', controller: :orgs, action: :show } # show.html.erb
      format.xml  { render xml: @abstracts }
      format.pdf do
        @pdf = true
        render pdf: "Abstracts for #{@unit.name}",
               stylesheets: ['pdf'],
               template: 'orgs/show.html.erb',
               layout: 'pdf'
      end
      format.xls do
        @pdf = true
        data = render_to_string(template: 'orgs/show.html', layout: 'excel')
        send_data(data,
                  filename: "Abstracts for #{@unit.name}.xls",
                  type: 'application/vnd.ms-excel',
                  disposition: 'attachment')
      end
      format.doc do
        @pdf = true
        data = render_to_string(template: 'orgs/show.html', layout: 'excel')
        send_data(data,
                  filename: "Abstracts for #{@unit.name}.doc",
                  type: 'application/msword',
                  disposition: 'attachment')
      end
    end
  end

  def investigator_abstracts_during_period
    # for printing
    handle_start_and_end_date
    @exclude_letters = ! params[:exclude_letters].blank?
    @impact_factor = params[:impact_factor]
    @limit_to_first_last = ! params[:limit_to_first_last].blank?
    @unit = OrganizationalUnit.new(:name=>'Ad hoc unit', :abbreviation=>'Ad hoc')
    @faculty = Investigator.find_investigators_in_list(params[:investigator_ids]).sort{|x,y| x.last_name+' '+x.first_name <=> y.last_name+' '+y.first_name}
    @investigators_in_unit = @faculty.map(&:id)
    if @exclude_letters
      @abstracts = Abstract.exclude_letters.investigator_publications_by_date( @faculty, params[:start_date], params[:end_date])
    else
      @abstracts = Abstract.investigator_publications_by_date( @faculty, params[:start_date], params[:end_date])
    end
    @do_pagination = '0'
    @heading = "#{@abstracts.length} publications. Selected publications  "
    @heading = @heading + " from #{@start_date} " if !params[:start_date].blank?
    @heading = @heading + " to #{@end_date}" if !params[:end_date].blank?
    @include_mesh = false
    @include_graph_link = false
    @show_paginator = false
    @include_investigators = true
    @include_pubmed_id = true
    @include_collab_marker = true
    @bold_members = true
    @include_impact_factor = true
    @simple_links = true

    respond_to do |format|
      format.html { render :layout => 'printable', :controller=> :orgs, :action => :show } # show.html.erb
      format.xml  { render :xml => @abstracts }
      format.pdf do
        @pdf = true
         render pdf: "Abstracts for #{@unit.name}",
                stylesheets: ['pdf'],
                template: 'orgs/show.html.erb',
                layout => 'pdf'
      end
      format.xls do
        @pdf = true
        data = render_to_string(template: 'orgs/show.html', layout: 'excel')
        send_data(data,
                  filename: "Abstracts for #{@unit.name}.xls",
                  type: 'application/vnd.ms-excel',
                  disposition: 'attachment')
      end
      format.doc do
        @pdf = true
        data = render_to_string(template: 'orgs/show.html', layout: 'excel')
        send_data(data,
                  filename: "Abstracts for #{@unit.name}.doc",
                  type: 'application/msword',
                  disposition: 'attachment')
      end
    end
  end

  def build_stats_array
    @exclude_letters = ! params[:exclude_letters].blank?
    @units = @head_node.children.sort do |x,y|
      x.sort_order.to_s.rjust(3,'0') + ' ' + x.abbreviation <=> y.sort_order.to_s.rjust(3,'0') + ' ' + y.abbreviation
    end
    @faculty_affiliation_types = params[:affiliation_types]
    @units.each do |unit|
      if @faculty_affiliation_types.blank?
        unit['All'] = build_unit_stats(unit, nil)
      else
        @faculty_affiliation_types.each do |affilliation_type|
          unit[affilliation_type] = build_unit_stats(unit, affilliation_type)
        end
      end
    end
    @units
  end
  private :build_stats_array

  def build_unit_stats(unit, affiliation_type)
    this_block = {}
    this_block["pi_intra_abstracts"] = Array.new
    this_block["pi_inter_abstracts"] = Array.new
    unit_faculty = unit.get_faculty_by_types([affiliation_type])
    this_block["unit_faculty"] = unit_faculty
    unit_pi_ids = unit_faculty.map(&:id)
    this_block["publications"] = Abstract.all_ccsg_publications_by_date(unit_pi_ids, params[:start_date], params[:end_date], @exclude_letters)
    this_block["publications"].each do |abstract|
      abstract_investigator_ids = abstract.investigators.collect{ |x| x.id }
      intra_collaborators_arr = abstract_investigator_ids & unit_pi_ids  # intersection of the two sets
      intra_collaborators = intra_collaborators_arr.length
      inter_collaborators = abstract_investigator_ids.length - intra_collaborators
      this_block["pi_inter_abstracts"].push(abstract) if inter_collaborators > 0
      this_block["pi_intra_abstracts"].push(abstract) if intra_collaborators > 1
    end
    this_block
  end
  private :build_unit_stats
end
