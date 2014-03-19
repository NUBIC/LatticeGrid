# -*- coding: utf-8 -*-
#
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  require 'config'

  before_filter :find_last_load_date, :except => [:set_investigator_abstract_end_date]
  before_filter :handle_year, :except => [:set_investigator_abstract_end_date]
  before_filter :get_organizations, :except => [:set_investigator_abstract_end_date]
  before_filter :handle_pagination, :except => [:set_investigator_abstract_end_date]
  before_filter :define_keywords, :except => [:set_investigator_abstract_end_date]

  def total_length(query)
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
    attr_reader :start_date, :end_date
    def initialize (start_date,end_date)
     @start_date = start_date.to_formatted_s(:justdate)
     @end_date = end_date.to_formatted_s(:justdate)
    end
  end

  def find_last_load_date
    if session[:last_load_date].blank? or session[:last_refresh].blank? or session[:last_refresh] < 1.day.ago then
      latest_record = LoadDate.order('id DESC').first
      if latest_record.blank? then
        session[:last_load_date] = (Time.now-100*365)
      else
        session[:last_load_date] = latest_record.updated_at
      end
      session[:last_refresh] = Time.now
      logger.info("Updated a session last_load_date for ip #{get_client_ip} at #{Time.now}")
    end
  end
  private :find_last_load_date

  def get_organizations
    @head_node = OrganizationalUnit.head_node(LatticeGridHelper.menu_head_abbreviation)
  end
  private :get_organizations

  def handle_start_and_end_date
    if ! params[:date_range].blank? then
      params[:start_date] = params[:date_range][:start_date]
      params[:end_date] = params[:date_range][:end_date]
    end
    if ! params[:program].blank? then
      params[:id] = params[:program][:id]
    end
    if params[:start_date].blank? and params[:end_date].blank? then
      @end_date = Date.today
      @start_date = 1.year.ago.to_date
      params[:start_date] = @start_date
      params[:end_date] = @end_date
    end
    if params[:start_date].blank? then
      @start_date = "01/01/#{@year}"
      params[:start_date] = @start_date
    else
      @start_date = params[:start_date]
    end
    if params[:end_date].blank? then
      @end_date = "12/01/#{@year}"
      params[:end_date] = @end_date
    else
      @end_date = params[:end_date]
    end
  end
  private :handle_start_and_end_date

  def handle_pagination
    @do_pagination = 1

    @do_pagination = cookies[:do_pagination] if !cookies[:do_pagination].blank?
    if !params[:do_pagination].blank? then
      @do_pagination = params[:do_pagination]
      cookies[:do_pagination] = @do_pagination
    end
  end
  private :handle_pagination

  ##
  # Simple struct to handle search parameters
  class Keywords
    attr_reader :keywords, :search_field, :search_exact
    def initialize(keywords, search_field, search_exact)
      @keywords = keywords
      @search_field = search_field
      @search_exact = search_exact
    end
  end

  def define_keywords(the_keywords = '', search_field = 'All', search_exact = '0')
    if params[:keywords].blank?
      the_keywords = cookies[:the_keywords] unless cookies[:the_keywords].blank?
    else
      the_keywords = params[:keywords]
      cookies[:the_keywords] = the_keywords
    end
    if !params[:search_field].blank?
      search_field = params[:search_field]
      cookies[:search_field] = search_field
    else
      search_field = cookies[:search_field] unless cookies[:search_field].blank?
    end
    if !params[:search_exact].blank?
      search_exact = params[:search_exact]
      cookies[:search_exact] = search_exact
    else
      search_exact = cookies[:search_exact] unless cookies[:search_exact].blank?
    end
    @keywords = Keywords.new(the_keywords, search_field, search_exact)
  end
  private :define_keywords

end
