class OrgsController < ApplicationController
  caches_page :show, :index, :departments, :centers, :programs, :show_investigators, :stats, :full_show, :tag_cloud, :short_tag_cloud
  helper :sparklines

  require 'fastercsv' # for department_collaborations

  # GET /orgs
  # GET /orgs.xml
  def index
    @units = OrganizationalUnit.find(:all, :order => "sort_order, lower(abbreviation)", :include => [:members,:organization_abstracts, :primary_faculty, :joint_faculty, :secondary_faculty])
    @heading = "Current Org Listing"
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @units }
    end
  end

  def department_collaborations
    year=2006
    edge_strength_to_graph=10
    @units = OrganizationalUnit.collaborations("9/1/#{year-1}","9/1/#{year}")
    @heading = "Departmental Collaborations for FY#{year}"
    #@units = OrganizationalUnit.collaborations("9/1/#{year-1}")
    #@heading = "Departmental Collaborations"
    respond_to do |format|
      format.html { render(:layout => 'scaled') }
      format.xml  { render :xml => @units }
      format.csv {
        unit_ids   = @units.collect(&:id)
        csv_string = FasterCSV.generate do |csv|
          # header row
          csv << [ "id", "name", "investigators", "total", "units" ] + @units.collect(&:name)
 
          # data rows
          @units.each do |unit|
            total_units =  unit_ids.collect{|unit_id| (unit_id == unit.id) ? 0 : unit.collaboration_matrix[unit_id].length }.sum
            csv << [unit.id, unit.name, unit.primary_faculty.length, unit.collaboration_matrix[unit.id].length, total_units ] + unit_ids.collect {|unit_id| (unit_id == unit.id) ? 0 : unit.collaboration_matrix[unit_id].length }
          end
        end

        # send it to the browser
        send_data csv_string,
                  :type => 'text/csv; charset=iso-8859-1; header=present',
                  :disposition => "attachment; filename=department_collaborations.csv"
      }
      format.dot {
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
        to_process= last-cnt
        nodes = []
        max_length = 0
        max_units = 0
        @units[cnt..last].each  { |outer_unit|
          cnt+=1
          total_units =  unit_ids.collect{|unit_id| (unit_id == outer_unit.id) ? 0 : outer_unit.collaboration_matrix[unit_id].length }.sum
          max_units = total_units if max_units < total_units
          @units[cnt..last].each  { |inner_unit|
            if outer_unit.collaboration_matrix[inner_unit.id].length > edge_strength_to_graph
              nodes << inner_unit.id
              nodes << outer_unit.id
              max_length  =outer_unit.collaboration_matrix[inner_unit.id].length if max_length < outer_unit.collaboration_matrix[inner_unit.id].length
            end
          }
        }
        nodes = nodes.sort.uniq
        # output the nodes
         @units.each { |unit| dot_string << ' node'+unit.id.to_s+' [label="'+unit.name+'" color='+node_color(unit_ids.collect{|unit_id| (unit_id == unit.id) ? 0 : unit.collaboration_matrix[unit_id].length }.sum,max_units)+']'+";\r" if nodes.include?(unit.id) }
        #create the edges
        cnt = 0 # start at zero or if you want to break this into shorter tasks, you could break it differently
        last = @units.length-1
        to_process= last-cnt
        @units[cnt..last].each  { |outer_unit|
          cnt+=1
          @units[cnt..last].each  { |inner_unit|
             if outer_unit.collaboration_matrix[inner_unit.id].length > edge_strength_to_graph
               pubs = outer_unit.collaboration_matrix[inner_unit.id].length
               the_length = (10-(pubs/(max_length/9))).to_i
              dot_string << ' node'+outer_unit.id.to_s+' -- node'+inner_unit.id.to_s+' [len='+the_length.to_s+' color='+color_scheme(the_length)+' label="'+pubs.to_s+' pubs"]'+";\r"
            end
          }
        }
        
        # complete the graph
        dot_string << "}\r" 
        
        # send it to the browser
        send_data dot_string,
                  :type => 'text/plain; charset=iso-8859-1; header=present',
                  :disposition => "attachment; filename=department_collaborations.dot"
      }
      
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

  def departments
    @units = Department.find(:all, :order => "sort_order, lower(abbreviation)", :include => [:members,:organization_abstracts, :primary_faculty, :joint_faculty, :secondary_faculty])
    @heading = "Current Department Listing"
    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @units }
    end
  end

  def centers
    @units = Center.find(:all, :order => "sort_order, lower(abbreviation)", :include => [:members,:organization_abstracts, :primary_faculty, :joint_faculty, :secondary_faculty])
    @heading = "Current Center Listing"
    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @units }
    end
  end

  def programs
    @units = Program.find(:all, :order => "sort_order, lower(abbreviation)", :include => [:members,:organization_abstracts, :primary_faculty, :joint_faculty, :secondary_faculty])
    @heading = "Center Programs Listing"
    @show_primary_faculty=false
    @show_associated_faculty=false
    @show_unit_type=false
    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { render :xml => @units }
    end
  end

  def show_investigators
    if params[:id].nil? then
      redirect_to index_orgs_path
    else
      @unit = OrganizationalUnit.find(params[:id])
      @heading = "Faculty Listing for '#{@unit.name}'"

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @unit }
        format.pdf do
           render :pdf => "Show Investigators for " + @unit.name, 
              :stylesheets => "pdf", 
              :template => "orgs/show_investigators.html.erb",
              :layout => "pdf"
        end
      end
    end
  end


  # GET /orgs/1
  # GET /orgs/1.xml
  def show
    redirect=false
    if params[:page].nil? then
      params[:page] = "1"
      redirect=true
    end
    if params[:id].nil? then
      redirect_to index_orgs_path
    elsif redirect then
      redirect_to params
    else
      show_pre
      @do_pagination = "1"
      @abstracts = @unit.abstract_data( params[:page] )
      @all_abstracts = @unit.get_minimal_all_data( )
      @heading   = "Publications (total of #{@abstracts.total_entries})"

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @abstracts }
      end
    end
  end

  def full_show
    redirect=false
    if params[:id].nil? then
      redirect_to index_orgs_path
    elsif !params[:page].nil? then
      params.delete(:page)
      redirect_to params
    else
      show_pre
      @do_pagination = "0"
      @abstracts =  @unit.display_year_data( @year )
      @all_abstracts =  @unit.get_minimal_all_data( )
      @heading   = "Publications during #{@year} (total of #{@abstracts.length})"
      render :action => 'show'
    end
  end

  def stats
    # get all publications by  members
    # then get the number of intra-unit collaborations and the number of inter-unit collaborations
    params[:start_date]=5.years.ago
    handle_start_and_end_date
    @heading = "Publication Statistics by Org for the past five years"
    @units = OrganizationalUnit.find(:all, :include => [:abstracts, :associated_faculty, :primary_faculty], :order => "lower(type) DESC, lower(search_name), lower(name), sort_order")
    @units.each do |unit|
      unit["pi_intra_abstracts"] = Array.new
      unit["pi_inter_abstracts"] = Array.new
      unit_pis = (unit.associated_faculty+unit.primary_faculty).collect{|x| x.id}
      unit.abstracts.each do |abstract| 
        abstract_investigators = abstract.investigator_abstracts.collect{|x| x.investigator_id}
        intra_collaborators_arr = abstract_investigators & unit_pis  # intersection of the two sets
        intra_collaborators = intra_collaborators_arr.length
        inter_collaborators = abstract_investigators.length - intra_collaborators
        unit.pi_inter_abstracts.push(abstract) if inter_collaborators > 0
        unit.pi_intra_abstracts.push(abstract) if intra_collaborators > 1
      end
    end
    render :layout => 'printable'
  end

  def tag_cloud
    org = OrganizationalUnit.find(params[:id])
    tags = org.abstracts.tag_counts(:limit => 150, :order => "count desc", :at_least => 10 )
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags, :org => org}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags, :org => org} }
    end
  end
  
  def short_tag_cloud
    investigator = Investigator.find(params[:id])
    tags = investigator.abstracts.tag_counts(:limit => 7, :order => "count desc" )
    respond_to do |format|
      format.html { render :template => "shared/tag_cloud", :locals => {:tags => tags, :investigator => investigator}}
      format.js  { render  :partial => "shared/tag_cloud", :locals => {:tags => tags, :investigator => investigator, :update_id => "short_tag_cloud_#{investigator.id}"} }
    end
  end 
 
  # these are not cached 

  def list
    handle_start_and_end_date
    @heading = "Publication Listing by Org "
    @heading = @heading + " for #{@year} " if params[:start_date].blank?
    @heading = @heading + " from #{@start_date} " if !params[:start_date].blank?
    @heading = @heading + " to #{@end_date}" if !params[:end_date].blank?
    render :layout => 'printable'
  end

  def list_abstracts_during_period_rjs
    handle_start_and_end_date
    @unit = OrganizationalUnit.find(params[:id])
    @abstracts = @unit.display_data_by_date( params[:start_date], params[:end_date] )
  end

  def abstracts_during_period
    # for printing
    handle_start_and_end_date
    @unit = OrganizationalUnit.find(params[:id])
    @abstracts = @unit.display_data_by_date( params[:start_date], params[:end_date] )
    @investigators_in_unit = (@unit.primary_faculty+@unit.associated_faculty).collect(&:id)

    @do_pagination = "0"
    @heading = "#{@abstracts.length} publications. Publication Listing  "
    @heading = @heading + " from #{@start_date} " if !params[:start_date].blank?
    @heading = @heading + " to #{@end_date}" if !params[:end_date].blank?
    @include_mesh = false
    @include_graph_link = false
    @show_paginator = false
    @include_investigators=true 
    @include_pubmed_id = true 
    @include_collab_marker = true

    respond_to do |format|
      format.html { render :layout => 'printable', :controller=> :orgs, :action => :show }# show.html.erb
      format.xml  { render :action => :show, :xml => @abstracts }
      format.pdf do
         render :pdf => "Abstracts for " + @unit.name, 
            :stylesheets => "pdf", 
            :template => "orgs/show.html.erb",
            :layout => "pdf"
      end
      
    end
  end

  private

  def show_pre
    @unit = OrganizationalUnit.find(params[:id])
  end
end
