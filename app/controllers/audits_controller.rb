class AuditsController < ApplicationController
  
  skip_before_filter  :handle_year
  skip_before_filter  :handle_pagination
  skip_before_filter  :define_keywords

  #caches_page( :show, :show_pubs ) if LatticeGridHelper.CachePages()
  before_filter :check_login
  
  #after_filter  :log_request, :except => [:login]
  after_filter :check_login

  require 'csv_generator' # has generate_csv method
  require 'cache_utilities'

  include Aker::Rails::SecuredController if LatticeGridHelper.require_authentication?
  include AuditsHelper
  include ProfilesHelper
  
  def view_logins
    @logs_after = LatticeGridHelper.logs_after
    @logs = Log.logins_after(@logs_after)
    @activity="logins"
    render_view_activities
  end

  def view_all_logins
    @logs = Log.logins
    @activity="logins"
    render_view_activities
  end

  def view_approved_profiles
    @logs_after = LatticeGridHelper.logs_after
    @logs = Log.approved_profiles_after(@logs_after)
    @activity="Profile Approvals"
    render_view_activities
  end
  
  def view_approved_publications
    @logs_after = LatticeGridHelper.logs_after
    @logs = Log.approved_publications_after(@logs_after)
    @activity="Publication Approvals"
    render_view_activities
  end

  def view_logins_without_approvals
    @logs_after = LatticeGridHelper.logs_after
    logins = Log.logins_by_investigator_id_after(@logs_after).map(&:investigator_id)
    approvals = Log.any_approval_by_investigator_id.map(&:investigator_id)
    @logs = Log.logins_for_investigator_ids(logins-approvals)
    @activity="Logins without approvals"
    @without_entries = []
    render_view_activities
  end

  def view_profile_approvers
    @logs_after = LatticeGridHelper.logs_after
    logs = Log.last_approved_profiles_by_id_after(@logs_after)
    @logs = Log.for_ids(logs.map(&:id))
    @activity="Profile Approvers"
    @log_entered = "Last Approved"
    render_view_activities
  end

  def view_publication_approvers
    @logs_after = LatticeGridHelper.logs_after
    logs = Log.last_approved_publications_by_id_after(@logs_after)
    @logs = Log.for_ids(logs.map(&:id))
    @activity="Publication Approvers"
    @log_entered = "Last Approved"
    render_view_activities
   end
  
  # calls for csv data by the amstock flash widget
  def faculty_data
    logs = Investigator.all
    data = generate_csv(logs, true)
    render :template => "shared/csv_data", :locals => {:data => data}, :layout => false
    
  end
  def login_data
    logs = Log.logins
    data = generate_csv(logs, true)
    render :template => "shared/csv_data", :locals => {:data => data}, :layout => false
  end
  
  def approved_profile_data
    @logs_after = LatticeGridHelper.logs_after
    logs = Log.approved_profiles_after(@logs_after)
    data = generate_csv(logs, true)
    render :template => "shared/csv_data", :locals => {:data => data}, :layout => false
  end
  
  def approved_publication_data
    @logs_after = LatticeGridHelper.logs_after
    logs = Log.approved_publications_after(@logs_after)
    data = generate_csv(logs, true)
    render :template => "shared/csv_data", :locals => {:data => data}, :layout => false
  end
  
  private

  def render_view_activities
    @without_entries = Investigator.complement_of_ids(@logs.map(&:investigator_id).compact.sort.uniq) unless defined?(@without_entries)
    @javascripts_add = ['prototype', 'scriptaculous', 'jquery.min', 'swfobject', 'jquery.tablesorter.min']
    @include_params = true unless params[:params].blank?
    respond_to do |format|
      format.html { render :view_activities, :layout=>'printable' }
      format.xml  { render :xml => @logs }
    end
  end
    
end
