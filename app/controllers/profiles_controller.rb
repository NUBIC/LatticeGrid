class ProfilesController < ApplicationController

  caches_page( :show, :show_pubs ) if LatticeGridHelper.CachePages()
  caches_action( :list_summaries )  if LatticeGridHelper.CachePages()
  before_filter :check_login
  after_filter  :log_request, :except => [:login, :welcome, :splash, :show_pubs, :edit, :edit_pubs, :ccsg]
  after_filter :check_login

  require 'cache_utilities'

  include Aker::Rails::SecuredController if LatticeGridHelper.require_authentication?
  include ProfilesHelper
  include InvestigatorsHelper
  include ApplicationHelper
  include AbstractsHelper
  include OrgsHelper

  include MeshHelper  #for the do_mesh_search method

  require 'publication_utilities' #all the helper methods
  require 'pubmed_utilities'  #loads including 'pubmed_config'  'bio' (bioruby) and
  # require 'pubmed_config' #look here to change the default time spans
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :search ], :redirect_to => :current_abstracts_url

  def index
    @username = (is_admin? ? params[:id] : current_user_model.username)
    @pronoun  = (is_admin? ? "" : " Your ")
    @username = current_user_model.username if @username.blank?
    if is_admin?
      @investigators = Investigator.by_name.to_a
      render :action => 'admin_index'
    else
      render
    end
  end

  def list_summaries
    if is_admin?
      @javascripts_add = ['jquery.tablesorter.min']
      @approvals_after = LatticeGridHelper.logs_after
      @investigators = Investigator.by_name
      render
    else
      redirect_to :index
    end
  end

  def list_orgs
    if is_admin?
      @center = Center.first
      @orgs = nil
      unless @center.blank?
        @orgs = @center.descendants.sort do |x,y|
          x.sort_order.to_s.rjust(3,'0')+' '+x.abbreviation <=> y.sort_order.to_s.rjust(3,'0')+' '+y.abbreviation
        end
      end
      render
    else
      redirect_to :index
    end
  end

  def edit_orgs
    if is_admin?
      @center = Center.first
      @orgs = nil
      unless @center.blank?
        @orgs = @center.descendants.sort do |x,y|
          x.sort_order.to_s.rjust(3,'0')+' '+x.abbreviation <=> y.sort_order.to_s.rjust(3,'0')+' '+y.abbreviation
        end
      end
      render
    else
      redirect_to :index
    end
  end

  def update_orgs
    if is_admin?
      programs_attributes = params[:center][:programs_attributes]
      programs_attributes.each do |key, program|
        # program should be a hash
        the_program = Program.find(program[:id])
        the_program.update_attributes(program.except(:id))
      end
    end
    redirect_to list_orgs_profiles_url
  end

  def list_summaries_by_program
    if is_admin?
      @javascripts_add = ['jquery.tablesorter.min']
      @approvals_after = LatticeGridHelper.logs_after
      @program = find_unit_by_id_or_name(params[:id])
      @investigators = @program.all_members.sort{ |a,b| a.sort_name.downcase <=> b.sort_name.downcase }
      respond_to do |format|
        format.html { render :action => 'list_summaries' }
        format.xml  { render :xml => @investigators }
        format.xls do
          @no_email = true
          send_data(render(:template => 'profiles/list_summaries', :layout => "excel"),
                    :filename => "summaries_listing_for_#{@program.name}.xls",
                    :type => 'application/vnd.ms-excel',
                    :disposition => 'attachment')
        end
        format.doc do
          @no_email = true
          send_data(render(:template => 'profiles/list_summaries', :layout => "excel"),
                    :filename => "summaries_listing_for_#{@program.name}.doc",
                    :type => 'application/msword',
                    :disposition => 'attachment')
        end
        format.pdf do
          @no_email = true
          render(:pdf => "summaries_listing_for_" + @program.name,
                 :stylesheets => ["pdf"],
                 :template => "profiles/list_summaries",
                 :layout => "pdf")
        end
      end
    else
      redirect_to :index
    end
  end

  def unreviewed_valid_abstracts
    if is_admin?
      render_abstract_listing(Abstract.valid_unreviewed)
    else
      redirect_to(current_abstracts_url)
    end
  end

  def reviewed_valid_abstracts
    if is_admin?
      render_abstract_listing(Abstract.valid_reviewed)
    else
      redirect_to(current_abstracts_url)
    end
  end

  def reviewed_invalid_abstracts
    if is_admin?
      render_abstract_listing(Abstract.invalid_reviewed)
    else
      redirect_to(current_abstracts_url)
    end
  end

  def reviewed_invalid_abstracts_with_investigators
    if is_admin?
      render_abstract_listing(Abstract.invalid_with_investigators_reviewed)
    else
      redirect_to(current_abstracts_url)
    end
  end

  def invalid_abstracts_with_investigators
    if is_admin?
      render_abstract_listing(Abstract.invalid_with_investigators)
    else
      redirect_to(current_abstracts_url)
    end
  end

  def unreviewed_invalid_abstracts
    if is_admin?
      render_abstract_listing(Abstract.invalid_unreviewed)
    else
      redirect_to(current_abstracts_url)
    end
  end

  def unreviewed_invalid_abstracts_with_investigators
    if is_admin?
      render_abstract_listing(Abstract.invalid_with_investigators_unreviewed)
    else
      redirect_to(current_abstracts_url)
    end
  end

  def ccsg
    @date_range = DateRange.new(1.year.ago,Time.now)
    @investigators = Investigator.order('last_name, first_name').to_a
    render :template => 'abstracts/ccsg.html', :layout => 'application.html'
  end

  def splash
    @username = (is_admin? ? params[:id] : current_user_model.username)
    @pronoun  = (is_admin? ? "" : " Your ")
    @username = current_user_model.username if @username.blank?
    handle_member_name
    render :action => 'index'
  end

  def show
    @username = (is_admin? ? params[:id] : current_user_model.username)
    @pronoun  = (is_admin? ? "" : " Your ")
    @username = current_user_model.username if @username.blank?
    handle_member_name
    if params[:id].nil? then
      redirect_to(current_abstracts_url)
    else
      @include_mesh = false
      @do_pagination = "1"
      @abstracts = Abstract.display_investigator_data(@investigator.id,params[:page] )
      @all_abstracts = Abstract.display_all_investigator_data(@investigator.id)
      @total_entries=@abstracts.total_entries
      respond_to do |format|
        format.html { render }
      end
    end
  end

  def edit
    @username = (is_admin? ? params[:id] : current_user_model.username)
    @pronoun  = (is_admin? ? "" : " Your ")
    @username = current_user_model.username if @username.blank?
    handle_member_name
    if params[:id].nil? then
      redirect_to(current_abstracts_url)
    else
      @include_all_mesh = true
      respond_to do |format|
        format.html { render }
      end
    end
  end

  def update
    @investigator = Investigator.find(params[:id])
    before_update(@investigator)
    flash[:notice] = params[:investigator].inspect
    if params[:commit] =~ /publication/i
      mark_investigator_abstracts_as_reviewed(@investigator)
    end
    respond_to do |format|
      if @investigator.update_attributes(params[:investigator])
        clear_directory("investigators/#{@investigator.username}")
        clear_file("profiles/#{@investigator.username}.html")
        flash[:notice] = 'Profile was successfully updated.'
        format.html { redirect_to(profiles_url }
        format.xml  { head :ok }
      else
        flash[:notice] += 'Profile could not be updated.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @investigator.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show_pubs
    handle_member_name
    if params[:id].nil? then
      redirect_to(current_abstracts_url)
    else
      @include_all_mesh = true
      respond_to do |format|
        format.html { render(:template=>'investigators/show') }
      end
    end
  end

  def recent
    @abstracts = Abstract.recently_changed
    @include_pubmed_id = true
    @include_collab_marker = false
    @include_investigators = true
    @show_valid_checkboxes = true
    @link_abstract_to_pubmed = true
    @include_impact_factor = false
    @include_updated_at = true
    @simple_links = false
    @speed_display = false
    @heading = "Recently changed publication abstracts (#{@abstracts.length})"
    render :action => 'investigator_listing'
  end

  def recent_unvalidated
    @abstracts = Abstract.recently_changed_unvalidated
    @include_pubmed_id = true
    @include_collab_marker = false
    @include_investigators = true
    @show_valid_checkboxes = true
    @link_abstract_to_pubmed = true
    @include_impact_factor = true
    @include_updated_at = true
    @simple_links = true
    @heading = "Recently changed publication abstracts without validation (#{@abstracts.length})"
    render :action => 'investigator_listing'
  end

  def edit_pubs
    @username = (is_admin? ? params[:id] : current_user_model.username)
    @pronoun  = (is_admin? ? "" : " Your ")
    @username = current_user_model.username if @username.blank?

    # prepare_edit_investigator_listing sets @investigator and some display conditions
    prepare_edit_investigator_listing
    @include_impact_factor = true
    investigator_id = 0
    investigator_id = @investigator.id if ! @investigator.blank?
    respond_to do |format|
      format.html do
        @javascripts = [ "prototype", "jquery.min"]
        @abstracts = Abstract.display_all_investigator_data_include_deleted(investigator_id)
        render
      end
    end
  end

  def admin_edit
    if params[:publications]
      redirect_to edit_pubs_profile_path(params[:investigator_id])
    else
      redirect_to edit_profile_path(params[:investigator_id])
    end
  end

  def investigator_listing
    prepare_edit_investigator_listing
    @include_impact_factor = true
    respond_to do |format|
      format.html do
      	@abstracts = Abstract.display_all_investigator_data_include_deleted(@investigator.id)
      	render
      end
      format.xml do
        @abstracts = Abstract.display_all_investigator_data(@investigator.id)
        render :xml => @abstracts
      end
      format.xls do
        @link_abstract_to_pubmed = true
        @abstracts = Abstract.display_all_investigator_data(@investigator.id)
        send_data(render(:template => 'abstracts/investigator_listing', :layout => "excel"),
                  :filename => "investigator_listing_for_#{@investigator.first_name}_#{@investigator.last_name}.xls",
                  :type => 'application/vnd.ms-excel',
                  :disposition => 'attachment')
      end
      format.doc do
        @link_abstract_to_pubmed = true
        @abstracts = Abstract.display_all_investigator_data(@investigator.id)
        send_data(render(:template => 'abstracts/investigator_listing.xls', :layout => "excel"),
                  :filename => "investigator_listing_for_#{@investigator.first_name}_#{@investigator.last_name}.doc",
                  :type => 'application/msword',
                  :disposition => 'attachment')
      end
      format.pdf do
        @link_abstract_to_pubmed = true
        @abstracts = Abstract.display_all_investigator_data(@investigator.id)
        @show_valid_checkboxes = false
        render(:pdf => "Publication Listing for " + @investigator.name,
               :stylesheets => ["pdf"],
               :template => "abstracts/investigator_listing.html",
               :layout => "pdf")
      end
    end
  end

  def list_investigators
    @investigators = Investigator.includes([:home_department,:appointments]).order('last_name, first_name').to_a
    respond_to do |format|
      format.html { render :template => "investigators/list_all.html" }
      format.xml  { render :xml => @units }
      format.pdf do
        @pdf = true
        render(:pdf => "Investigator Listing",
               :stylesheets => ["pdf"],
               :template => "investigators/list_all.html",
               :layout => "pdf")
      end
    end
  end

  def edit_investigators
    @javascripts_add = ['prototype', 'scriptaculous', 'effects', 'jquery.min']
    @investigators = Investigator.includes([:home_department,:appointments]).order('last_name, first_name').to_a
    respond_to do |format|
      format.html { render }
    end
  end

  def reminder
    if params[:id].nil? or not is_admin? then
      redirect_to(current_abstracts_url)
    else
      handle_member_name(false)
      if @investigator.blank?
        redirect_to( current_abstracts_url)
      else
        respond_to do |format|
          begin
            Notifier.reminder_message(@investigator).deliver
          rescue Exception => err
            logger.error "Error occured. Unable to send notification email to #{@investigator.name} at #{@investigator.email}. Error: #{err.message}"
            pass = false
          end

          flash[:notice] = "Reminder was successfully sent to #{@investigator.name}."
          format.html { redirect_to(splash_profiles_path) }
          format.xml  { head :ok }
        end
      end
    end
  end

  def mark_investigator_abstracts_as_reviewed(investigator)
    investigator.abstracts.each do |abstract|
      before_abstract_save(abstract)
      abstract.save!
    end
    investigator.investigator_abstracts.each do |ia|
      before_abstract_save(ia)
      ia.save!
    end
  end
  private :mark_investigator_abstracts_as_reviewed

  def render_abstract_listing(abstracts)
    @abstracts = abstracts
    respond_to do |format|
      format.html { render :template => 'profiles/abstracts_listing' }
      format.xml  { render :xml => @abstracts }
      format.xls do
        @link_abstract_to_pubmed = true
        send_data(render(:template => 'profiles/abstracts_listing', :layout => "excel"),
                  :filename => "abstracts_listing.xls",
                  :type => 'application/vnd.ms-excel',
                  :disposition => 'attachment')
      end
      format.doc do
        @link_abstract_to_pubmed = true
        send_data(render(:template => 'profiles/abstracts_listing', :layout => "excel"),
                  :filename => "abstracts_listing.doc",
                  :type => 'application/msword',
                  :disposition => 'attachment')
       end
      format.pdf do
       @link_abstract_to_pubmed = true
       @show_valid_checkboxes = false
       render(:pdf => "Abstracts listing",
              :stylesheets => ["pdf"],
              :template => 'profiles/abstracts_listing',
              :layout => "pdf")
      end
    end
  end
  private :render_abstract_listing
end
