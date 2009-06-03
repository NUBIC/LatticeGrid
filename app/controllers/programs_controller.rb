class ProgramsController < ApplicationController
  caches_page :show_program_abstracts, :index, :show_investigators, :program_stats, :full_show_program_abstracts
  helper :sparklines
  # GET /programs
  # GET /programs.xml
  def index
    @programs = Program.find(:all, :order => "program_number", :include => [:investigator_programs,:program_abstracts])
    @heading = "Current Program Listing"
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @programs }
    end
  end


  def list_programs
    handle_start_and_end_date
    # @programs is called in application.rb for every request
    @heading = "Publication Listing by Program "
    @heading = @heading + " for #{@year} " if params[:start_date].blank?
    @heading = @heading + " from #{@start_date} " if !params[:start_date].blank?
    @heading = @heading + " to #{@end_date}" if !params[:end_date].blank?
    render :layout => 'printable'
   end

  def show_investigators
    if params[:id].nil? then
      redirect_to index_programs_path
    else
      @tags =   Program.find(params[:id]).abstracts.tag_counts(:limit => 150, :order => "count desc", :at_least => 20 )
      @program = Program.find(params[:id])

      @investigators = Investigator.find :all, 
          :order => "last_name ASC, first_name ASC",
          :include => ["programs"],
          :conditions => ["programs.id =:program_id",
            {:program_id => params[:id]}]
      @heading = "Faculty Listing in Program '#{@program.program_title}'"

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @program }
      end
    end
  end


  def list_abstracts_during_period_rjs
    handle_start_and_end_date
    # @program = Program.display_abstracts_by_date( params[:id], params[:start_date], params[:end_date] )
    # @abstracts = @program.abstracts
    @program = Program.find(params[:id])
    @abstracts = Abstract.display_program_data_by_date( params[:id], params[:start_date], params[:end_date] )
  end

  def abstracts_during_period
    # for printing
    handle_start_and_end_date
     # @programs is called in application.rb for every request
     # @program = Program.display_abstracts_by_date( params[:id], params[:start_date], params[:end_date] )
     # @abstracts = @program.abstracts
     @program = Program.find(params[:id])
     @abstracts = Abstract.display_program_data_by_date( params[:id], params[:start_date], params[:end_date] )
     @investigators_in_program = Investigator.program_members(params[:id]).collect{|x| x.id }
 
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
      format.html { render :layout => 'printable', :controller=> :programs, :action => :show }# show.html.erb
      format.xml  { render :action => :show, :xml => @program }
    end
  end
  
  # GET /programs/1
  # GET /programs/1.xml
  def show
    redirect=false
    if params[:page].nil? then
      params[:page] = "1"
      redirect=true
    end
    if params[:id].nil? then
      redirect_to index_programs_path
    elsif redirect then
      redirect_to params
    else
      show_pre
      @do_pagination = "1"
        @abstracts = Abstract.display_program_data( @program.id, params[:page] )
        @all_abstracts = Abstract.get_minimal_all_program_data( @program.id )
        @heading   = "Publications (total of #{@abstracts.total_entries})"
  
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @program }
      end
    end
  end


  def full_show
    redirect=false
    if params[:id].nil? then
      redirect_to index_programs_path
    elsif !params[:page].nil? then
      params.delete(:page)
      redirect_to params
    else
      show_pre
      @do_pagination = "0"
      @abstracts =  Abstract.display_all_program_data( @program.id, @year )
      @all_abstracts = Abstract.get_minimal_all_program_data( @program.id )
      @heading   = "Publications during #{@year} (total of #{@abstracts.length})"
      render :action => 'show'
    end
  end

  def program_stats
    # get all publications by program members
    # then get the number of intra-program collaborations and the number of inter-program collaborations
    params[:start_date]=5.years.ago
    handle_start_and_end_date
    @heading = "Publication Statistics by Program for the past five years"
    @programs = Program.find(:all, :include => [:abstracts, :investigators], :order => "program_number")
    @programs.each do |program|
      program["pi_intra_abstracts"] = Array.new
      program["pi_inter_abstracts"] = Array.new
      program_pis = program.investigators.collect{|x| x.id}
      program.abstracts.each do |abstract| 
        abstract_investigators = abstract.investigator_abstracts.collect{|x| x.investigator_id}
        intra_collaborators_arr = abstract_investigators & program_pis  # intersection of the two sets
        intra_collaborators = intra_collaborators_arr.length
        inter_collaborators = abstract_investigators.length - intra_collaborators
         program.pi_inter_abstracts.push(abstract) if inter_collaborators > 0
         program.pi_intra_abstracts.push(abstract) if intra_collaborators > 1
      end
    end
  end
   private
   def show_pre
     @program = Program.find(params[:id])
     @tags =   Program.find(params[:id]).abstracts.tag_counts(:limit => 150, :order => "count desc", :at_least => 20 )
   end
 end
