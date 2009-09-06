# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all, :application
  include ApplicationHelper
  # Pick a unique cookie name to distinguish our session data from others'
#  session :session_key => '_nucatspublications_session_id'
  before_filter  :find_last_load_date 
  before_filter  :handle_year
  before_filter  :get_organizations
  before_filter  :handle_pagination
  before_filter  :define_keywords 

  def  total_length(query) 
    return if query.nil?
    begin 
      query.total_entries
    rescue Exception => error
      query.length
    end
  end

  def get_client_ip
    request.remote_ip 
  end

  class DateRange
    def initialize (start_date,end_date)
     @start_date = start_date.to_formatted_s(:justdate)
     @end_date = end_date.to_formatted_s(:justdate)
    end
    def start_date 
     @start_date
    end
    def end_date
     @end_date
    end
  end

  private
  def find_last_load_date
    if session[:last_load_date].blank? or session[:last_refresh].blank? or session[:last_refresh] < 1.day.ago then
      latest_record = LoadDate.find(:first, :order => "id DESC")
      if latest_record.blank? then
        session[:last_load_date] = (Time.now-100*365)
      else
        session[:last_load_date] = latest_record.updated_at
      end
      session[:last_refresh] = Time.now
      logger.info("Updated a session last_load_date for ip #{get_client_ip} at #{Time.now}") 
    end
  end

  def get_organizations
    @head_node = OrganizationalUnit.head_node(menu_head_abbreviation)
  end

  def handle_year (year=nil)
    @starting_year=Time.now.year
    @year_array = (@starting_year-9 .. @starting_year).to_a
    @year_array.reverse!
    @year = @starting_year.to_s
    @year = cookies[:the_year] if !cookies[:the_year].blank?
    if !year.blank? then
      cookies[:the_year] = year
      @year = year
    end
  end

  def handle_start_and_end_date
    if ! params[:date_range].blank? then
      params[:start_date]=params[:date_range][:start_date]
      params[:end_date]=params[:date_range][:end_date]
    end
    if ! params[:program].blank? then
      params[:id]=params[:program][:id]
    end
    if params[:start_date].blank? then
      @start_date = "01/01/#{@year}"
    else
      @start_date = params[:start_date]
    end
    if params[:end_date].blank? then
      @end_date = "12/01/#{@year}"
    else
      @end_date = params[:end_date]
    end
  end

  def handle_pagination
    @do_pagination = 1

    @do_pagination = cookies[:do_pagination] if !cookies[:do_pagination].blank?
    if !params[:do_pagination].blank? then
      @do_pagination = params[:do_pagination]
      cookies[:do_pagination] = @do_pagination
    end
  end

  class Keywords
    def initialize (keywords,search_field,search_exact)
      @keywords = keywords
      @search_field = search_field
      @search_exact = search_exact
    end
    def keywords 
      @keywords
    end
    def search_field
      @search_field
    end
    def search_exact
      @search_exact
    end
  end

  def define_keywords (keywords='', search_field='All', search_exact='0')
    if !params[:keywords].nil? && !params[:keywords][:keywords].nil? then
      keywords = params[:keywords][:keywords] 
      cookies[:the_keywords] = keywords
    else
      keywords = cookies[:the_keywords] if !cookies[:the_keywords].blank?
    end
    if !params[:keywords].nil? && !params[:keywords][:search_field].nil? then
      search_field = params[:keywords][:search_field] 
      cookies[:search_field] = search_field
    else
      search_field = cookies[:search_field] if !cookies[:search_field].blank?
    end
    if !params[:keywords].nil? && !params[:keywords][:search_exact].nil? then
      search_exact = params[:keywords][:search_exact] 
      cookies[:search_exact] = search_exact
    else
      search_exact = cookies[:search_exact] if !cookies[:search_exact].blank?
    end
    @keywords = Keywords.new(keywords,search_field,search_exact)
  end

end
