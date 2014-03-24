# -*- coding: utf-8 -*-

##
# Controller to show Investigators
class InvestigatorsController < ApplicationController

  caches_page(:show, :full_show, :list_all, :listing) if LatticeGridHelper.cache_pages?
  caches_page(:tag_cloud_side, :tag_cloud, :show_all_tags, :publications, :tag_cloud_list) if LatticeGridHelper.cache_pages?
  caches_page(:abstract_count, :preview, :search, :bio, :barchart, :collaborators, :home_department) if LatticeGridHelper.cache_pages?

  helper :all

  include InvestigatorsHelper
  include ApplicationHelper
  include SparklinesHelper

  require 'pubmed_utilities'

  # <iframe frameborder="0" src="http://www.tagxedo.com/art/f6f2d766fb9d47e6" width="300" height="300" scrolling="no"></iframe>
  skip_before_filter  :find_last_load_date, only: [:tag_cloud_side, :tag_cloud, :search, :collaborators, :barchart]
  skip_before_filter  :handle_year, only: [:tag_cloud_side, :tag_cloud, :search, :collaborators, :barchart]
  skip_before_filter  :get_organizations, only: [:tag_cloud_side, :tag_cloud, :search, :collaborators, :barchart]
  skip_before_filter  :handle_pagination, only: [:tag_cloud_side, :tag_cloud, :search, :collaborators, :barchart]
  skip_before_filter  :define_keywords, only: [:tag_cloud_side, :tag_cloud, :search, :collaborators, :barchart]

  def index
    redirect_to current_abstracts_url
  end

  def list_all
    @investigators = Investigator.includes([:home_department, :appointments]).order('last_name, first_name').to_a
    respond_to do |format|
      format.html { render layout: 'printable' }
      format.xml { render xml: @units }
      format.pdf do
        @pdf = true
        render(pdf: 'Investigator Listing',
               stylesheets: ['pdf'],
               template: 'investigators/list_all.html',
               layout: 'pdf')
      end
      format.xls do
        @pdf = true
        data = render_to_string(template: 'investigators/list_all.html', layout: 'excel')
        send_data(data,
                  filename: "Investigator_Listing_#{Date.today.to_s}.xls",
                  type: 'application/vnd.ms-excel',
                  disposition: 'attachment')
      end
      format.doc do
        @pdf = true
        data = render_to_string(template: 'investigators/list_all.html', layout: 'excel')
        send_data(data,
                  filename: "Investigator_Listing_#{Date.today.to_s}.doc",
                  type: 'application/msword',
                  disposition: 'attachment')
      end
    end
  end

  def list_by_ids
    if params[:investigator_ids].nil?
      redirect_to year_list_abstracts_url
    else
      @investigators = Investigator.find_investigators_in_list(params[:investigator_ids]).sort do |x, y|
        x.last_name + ' ' + x.first_name <=> y.last_name + ' ' + y.first_name
      end
      respond_to do |format|
        format.html { render action: 'list_all', layout: 'printable' }
        format.xml { render xml: @investigators }
        format.pdf do
          @pdf = true
          render(pdf: 'Investigator Listing',
                 stylesheets: ['pdf'],
                 template: 'investigators/list_all.html',
                 layout: 'pdf')
        end
        format.xls do
          @pdf = true
          data = render_to_string(template: 'investigators/list_all.html', layout: 'excel')
          send_data(data,
                    filename: 'Investigator Listing.xls',
                    type: 'application/vnd.ms-excel',
                    disposition: 'attachment')

        end
        format.doc do
          @pdf = true
          data = render_to_string(template: 'investigators/list_all.html', layout: 'excel')
          send_data(data,
                    filename: 'Investigator Listing.doc',
                    type: 'application/msword',
                    disposition: 'attachment')
        end
      end
    end
  end

  def listing
    @javascripts_add = ['jquery-1.8.3', 'jquery.tablesorter.min', 'jquery.fixheadertable.min']
    @investigators = Investigator.where('total_publications > 2').order('total_publications desc').limit(3000).to_a
    respond_to do |format|
      format.html { render layout: 'printable' }
      format.xml { render xml: @investigators }
      format.pdf do
        @pdf = true
        render(pdf: 'Investigator Listing',
               stylesheets: ['pdf'],
               template: 'investigators/listing.html',
               layout: 'pdf')
      end
    end
  end

  def collaborators
    # converts params[:id] to params[:investigator_id] and sets @investigator
    handle_member_name(false)
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def barchart
    # converts params[:id] to params[:investigator_id] and sets @investigator
    handle_member_name(false)
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def full_show
    if params[:id].nil?
      redirect_to year_list_abstracts_url
    elsif !params[:page].nil?
      params.delete(:page)
      # FIXME: redirect_to params does not work in Rails 3
      redirect_to params
    else
      handle_member_name # converts params[:id] to params[:investigator_id] and sets @investigator
      @do_pagination = '0'
      @heading = 'Selected publications from 2004-2013' if LatticeGridHelper.get_default_school == 'UMDNJ'
      @abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
      @all_abstracts = @abstracts
      @total_entries = @abstracts.length
      respond_to do |format|
        format.html { render action: 'show' }
        format.xml { render layout: false, xml: @abstracts.to_xml }
        format.pdf do
          @pdf = true
          render(pdf: "Publications for #{@investigator.full_name}",
                 stylesheets => ['pdf'],
                 template: 'investigators/show.html',
                 layout: 'pdf')
        end
      end
    end
  end

  def publications
    # set variables used in show
    handle_member_name # sets @investigator
    @do_pagination = '0'
    @abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
    @all_abstracts = @abstracts
    @total_entries = @abstracts.length

    respond_to do |format|
      format.html { render action: 'show' }
      format.json { render layout: false, json: @abstracts.as_json }
      format.xml  { render layout: false, xml: @abstracts.to_xml }
    end
  end

  def abstract_count
    # set variables used in show
    handle_member_name(false) # sets @investigator
    investigator = @investigator
    abstract_count = 0
    tags = ''
    unless investigator.nil?
      abstract_count = investigator.abstracts.length
      tags = investigator.tags.map(&:name).join(', ')
    end
    respond_to do |format|
      format.html do
        render text: "abstract count = #{abstract_count},  tags = #{tags}, investigator_id = #{params[:investigator_id]}"
      end
      format.json do
        data = {
          'abstract_count' => abstract_count,
          'tags' => tags,
          'investigator_id' => params[:investigator_id] }
        render layout: false, json: data.as_json
      end
      format.xml do
        data = {
          'abstract_count' => abstract_count,
          'tags' => tags,
          'investigator_id' => params[:investigator_id] }
        render layout: false, xml: data.to_xml
      end
    end
  end

  def show_colleagues
    handle_member_name(false)
    investigator = @investigator
    coauthors = investigator.co_authors
    colleagues = []
    ugh = ''
    unless investigator.nil?
      ugh = coauthors.map(&:publication_cnt).join(', ')
      coauthors.each { |ca| colleagues << ca.colleague }
      lol = ''
      lol = colleagues.map(&:name).join(', ')
    end
    respond_to do |format|
      format.html do
        render text: "colleague count = #{investigator.co_authors.length}, who are #{lol} their respective publication counts #{ugh}"
      end
    end
  end

  def show
    if params[:id].nil?
      redirect_to year_list_abstracts_url
    elsif params[:page].nil?
      params[:page] = '1'
      # FIXME: redirect_to params does not work in Rails 3
      redirect_to params
    else
      handle_member_name # sets @investigator
      @heading = 'Selected publications from 2004-2013' if LatticeGridHelper.get_default_school == 'UMDNJ'
      @do_pagination = '1'
      @abstracts = Abstract.display_investigator_data(params[:investigator_id], params[:page])
      @all_abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
      @include_pubmed_id = true unless params[:include_pubmed_id].blank?
      @total_entries = @abstracts.total_entries
    end
  end

  def show_all_tags
    if params[:id].nil?
      redirect_to year_list_abstracts_url
    elsif params[:page].nil?
      params[:page] = '1'
      # FIXME: redirect_to params does not work in Rails 3
      redirect_to params
    else
      handle_member_name # sets @investigator
      @do_pagination = '1'
      @abstracts = Abstract.display_investigator_data(params[:investigator_id], params[:page])
      @all_abstracts = Abstract.display_all_investigator_data(params[:investigator_id])
      @total_entries = @abstracts.total_entries
      @include_all_mesh = true
      respond_to do |format|
        format.html { render action: :show }
      end
    end
  end

  def tag_cloud_side
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    tags = investigator.abstracts.tag_counts(limit: 15, order: 'count desc')
    respond_to do |format|
      format.html { render template: 'shared/tag_cloud', locals: { tags: tags, investigator: investigator } }
      format.js  { render partial: 'shared/tag_cloud', locals: { tags: tags, investigator: investigator, update_id: 'tag_cloud_side', include_breaks: true } }
    end
  end

  def tag_cloud
    handle_member_name(false)
    respond_to do |format|
      format.html do
        tags = @investigator.abstracts.map { |ab| ab.tags.map(&:name) }.flatten
        render text: tags.join(', ')
      end
      format.js do
        tags = @investigator.abstracts.tag_counts(order: 'count desc')
        render partial: 'shared/tag_cloud', locals: { tags: tags }
      end
    end
  end

  def research_summary
    handle_member_name(false)
    if @investigator.blank?
      summary = ''
    else
      summary = @investigator.faculty_research_summary
      summary = @investigator.investigator_appointments.map(&:research_summary).join('; ') if summary.blank?
    end
    respond_to do |format|
      format.html { render text: summary }
      format.js   { render json: summary.as_json }
      format.json { render json: summary.as_json }
    end
  end

  def title
    handle_member_name(false)
    title = @investigator.try(:title).to_s
    respond_to do |format|
      format.html { render text: title }
      format.js   { render json: title.as_json }
      format.json { render json: title.as_json }
    end
  end

  def email
    handle_member_name(false)
    email = @investigator.try(:email).to_s
    respond_to do |format|
      format.html { render text: email }
      format.js   { render json: email.as_json }
      format.json { render json: email.as_json }
    end
  end

  def home_department
    handle_member_name
    home_department_name = ''
    home_department_name = determine_home_department_name(@investigator) unless @investigator.blank?
    respond_to do |format|
      format.html { render text: home_department_name }
      format.js   { render json: home_department_name.as_json }
      format.json { render json: home_department_name.as_json }
    end
  end

  def determine_home_department_name(investigator)
    home_department_name = investigator.home_department_name
    home_department_name = investigator.home_department.try(:name) if home_department_name.blank?
    home_department_name = investigator.try(:home) if home_department_name.blank?
    home_department_name
  end
  private :determine_home_department_name

  def affiliations
    handle_member_name(false)
    affiliations = []
    @investigator.appointments.each { |appt| affiliations << [appt.name, appt.division_id, appt.id] }
    respond_to do |format|
      format.html { render text: affiliations.join('; ') }
      format.js   { render json: affiliations.as_json }
      format.json { render json: affiliations.as_json }
    end
  end

  def bio
    handle_member_name
    home_department_name = ''
    if @investigator.blank?
      render text: 'investigator not found'
    else
      home_department_name = determine_home_department_name(@investigator)
      investigator = @investigator
      summary = investigator.faculty_research_summary
      summary = investigator.investigator_appointments.map(&:research_summary).join('; ') if summary.blank?
      affiliations = []
      investigator.appointments.each { |appt| affiliations << [appt.name, appt.division_id, appt.id] }
      respond_to do |format|
        format.html { render text: summary }
        format.js do
          render json: {
            'name' => investigator.full_name,
            'title' => investigator.title,
            'publications_count' => investigator.total_publications,
            'home_department' => home_department_name,
            'research_summary' => summary,
            'email' => investigator.email,
            'affiliations' => affiliations }.as_json
        end
        format.json do
          render json: {
            'name' => investigator.full_name,
            'title' => investigator.title,
            'publications_count' => investigator.total_publications,
            'home_department' => home_department_name,
            'research_summary' => summary,
            'email' => investigator.email,
            'affiliations' => affiliations }.as_json
        end
      end
    end
  end

  #:title => :get, :bio=>:get, :email=>:get, :affiliations=>:get

  # Differs from above because the Investigator is found by username instead of id
  # Then it will send a json response to the requester
  def tag_cloud_list
    if params[:id] =~ /^\d+$/
      investigator = Investigator.include_deleted(params[:id])
    else
      investigator = Investigator.find_by_username_including_deleted(params[:id])
    end
    result = []
    tags = investigator.abstracts.tag_counts(limit: 15, order: 'count desc')
    tags.each { |tag| result << [tag.name, tag.count] }
    render json: result.as_json
  end

  # this is /investigators_search_all
  def search
    params[:id] = params[:keywords] if params[:id].blank? && !params[:keywords].blank?

    if params[:id].blank?
      logger.error 'search did not have a defined keyword'
      year_list  # includes a render
    else
      @investigators = Investigator.all_tsearch(params[:id])
      @heading = "There were #{@investigators.length} matches to search term <i>#{params[:id].downcase}</i>".html_safe
      @include_mesh = false
      render action: :index, layout: 'searchable'
    end
  end

  # this is /investigators_search
  def investigators_search
    params[:id] = params[:keywords] if params[:id].blank? && !params[:keywords].blank?

    if params[:id].blank?
      logger.error 'search did not have a defined keyword'
      year_list  # includes a render
    else
      @investigators = Investigator.investigators_tsearch(params[:id])
      if @investigators.length == 1
        redirect_to show_investigator_path(id: @investigators[0].username, page: 1)
      else
        @heading = "There were #{@investigators.length} matches to search term <i>#{params[:id].downcase}</i>".html_safe
        @include_mesh = false
        render action: :index, layout: 'searchable'
      end
    end
  end

  def preview
    if params[:id].blank?
      logger.error 'search did not have a defined keyword'
      year_list  # includes a render
    else
      @investigators = Investigator.top_ten_tsearch(params[:id])
      render action: :preview, layout: 'preview'
    end
  end

  def direct_search
    logger.error "direct_search called with #{params[:id]}"
    if params[:id].blank?
      logger.error 'search did not have a defined keyword'
      @search_length = 0
    else
      @search_length = Investigator.count_all_tsearch(params[:id])
    end
    render layout: false, template: 'investigators/direct_search.xml'  # direct_search.xml.builder
    logger.error "direct_search completed with #{params[:id]}"
  end
end
