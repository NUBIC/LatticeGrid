# -*- coding: utf-8 -*-
##
# Controller to show publications/abstracts
class AbstractsController < ApplicationController

  caches_page(:show, :high_impact, :high_impact_by_month, :year_list, :full_year_list, :current) if LatticeGridHelper.CachePages
  caches_page(:tag_cloud, :endnote, :tagged_abstracts, :full_tagged_abstracts, :tag_cloud_by_year) if LatticeGridHelper.CachePages

  include AbstractsHelper
  include ApplicationHelper
  include ProfilesHelper
  include MeshHelper # for the do_mesh_search method

  require 'publication_utilities'
  require 'pubmed_utilities' # loads including 'pubmed_config' 'bio' (bioruby) and

  def index
    year = handle_year
    redirect_to abstracts_by_year_url(id: year, page: '1')
  end

  def current
    index
  end

  def journal_list
    params[:page] ||= 1
    pre_list(1)
    if @redirect
      # FIXME: redirect_to params does not work in Rails 3
      redirect_to params
    else
      journal = Journal.find(params[:id])
      @abstracts = journal.publications
      journal_heading(capitalize_words(journal.journal_abbreviation))
      @include_mesh = false
      @include_graph_link = false
      @show_paginator = false
      @include_investigators = true
      @include_pubmed_id = true
    end
  end

  def year_list
    year = handle_year(params[:id])
    pre_list(year)
    if @redirect
      # FIXME: redirect_to params does not work in Rails 3
      redirect_to params
    else
      @abstracts = Abstract.display_data(year, params[:page])
      list_heading(year)
      @do_pagination = '1'
    end
  end

  def full_year_list
    year = handle_year(params[:id])
    if params[:id].nil?
      redirect_to abstracts_by_year_url(id: year, page: '1')
    elsif !params[:page].nil? then
      params.delete(:page)
      # FIXME: redirect_to params does not work in Rails 3
      redirect_to params
    else
      @redirect = false
      @abstracts = Abstract.display_all_data(year)
      list_heading(year)
      @do_pagination = '0'
      render action: 'year_list'
    end
  end

  def tag_cloud_by_year
    year = handle_year(params[:id])
    @tags = Abstract.tag_counts(limit: 150, order: 'count desc',
                                conditions: ['abstracts.year in (:year)', { year: year }])
    respond_to do |format|
      format.html { render template: 'shared/tag_cloud', locals: { tags: @tags } }
      format.js { render  partial: 'shared/tag_cloud', locals: { tags: @tags } }
    end
  end

  def tag_cloud
    tag_limit = 300
    @heading = "MeSH Top #{tag_limit} Terms Tag Cloud Incidence for All Abstracts"
    @tags = Abstract.tag_counts(limit: tag_limit, order: 'count desc')
  end

  # abstracts tagged with this tag
  def tagged_abstracts
    page = params[:page].nil? ? '1' : nil
    if params[:id].nil?
      year = handle_year
      redirect_to abstracts_by_year_url(id: year, page: '1')
    elsif page
      redirect_to "/abstracts/#{params[:id]}/tagged_abstracts/?page=#{page}"
    else
      @do_pagination = '1'
      params[:id] = URI.unescape(params[:id])
      mesh_terms = MeshHelper.do_mesh_search(params[:id])
      mesh_names = mesh_terms.map(&:name)

      @abstracts = Abstract._paginate_tagged_with(mesh_names,
                                                  order: 'year DESC, authors ASC',
                                                  page: params[:page],
                                                  per_page: 20)
      tag_heading(params[:id], @abstracts)
      render action: 'tag'
    end
  end

  def full_tagged_abstracts
    @do_pagination = "0"
    params[:id] = URI.unescape(params[:id])
    mesh_terms = MeshHelper.do_mesh_search(params[:id])
    mesh_names = mesh_terms.collect(&:name)
    @abstracts = Abstract.find_tagged_with(mesh_names, :order => 'year DESC, authors ASC')
    tag_heading(mesh_names.join(", "),@abstracts)
    render :action => 'tag'
  end


  def impact_factor
    params[:year]||=""
    params[:sortby]||="article_influence_score desc"
    @journals = Journal.journal_publications(params[:year], params[:sortby])
    @missing_journals = Abstract.missing_impact_factors(params[:year])
    @high_impact_pubs = Journal.high_impact_publications(params[:year])
    @all_pubs = Abstract.annual_data(params[:year])

    respond_to do |format|
      format.html { render :layout => 'printable' }
      format.xml  { render :xml => @all_pubs }
      format.xls  {
        send_data(render(:template => 'abstracts/impact_factor.html', :layout => "excel"),
          :filename => "impact_factor_for_year_#{params[:year]}.xls",
          :type => 'application/vnd.ms-excel',
          :disposition => 'attachment') }
      format.doc  {
        send_data(render(:template => 'abstracts/impact_factor.html', :layout => "excel"),
          :filename => "impact_factor_for_year_#{params[:year]}.doc",
          :type => 'application/msword',
          :disposition => 'attachment') }
      format.pdf do
         render(:pdf => "High Impact publications for " + params[:year],
            :stylesheets => ["pdf"],
            :template => "abstracts/impact_factor.html",
            :layout => "pdf")
      end
    end
  end

  def high_impact
    @high_impact = Journal.preferred_high_impact()
    @high_impact = Journal.high_impact() if @high_impact.blank?
    respond_to do |format|
      format.html {render :layout => 'printable'}
      format.pdf do
        @pdf = 1
        render(:pdf => "High Impact journals",
            :stylesheets => ["pdf"],
            :template => "abstracts/high_impact.html",
            :layout => "pdf")
      end
    end
  end

  def high_impact_by_month
    @high_impact_issns = Journal.preferred_high_impact_issns()
    @high_impact_issns = Journal.high_impact_issns() if @high_impact_issns.blank?
    @abstracts = Abstract.recents_by_issns(@high_impact_issns.map(&:issn))
    respond_to do |format|
      format.html {render :layout => 'high_impact'}
      format.pdf do
        render( :pdf => "Recent high impact by month",
            :stylesheets => ["high_impact"],
            :template => "abstracts/high_impact_by_month.html",
            :layout => "high_impact")
      end
    end
  end

  def feed
    # this will be the name of the feed displayed on the feed reader
    @title = "LatticeGrid Recent Publications"

    # this will be our Feed's update timestamp
    @updated = session[:last_load_date]

    params[:limit] ||= 100
    if !@keywords.keywords.blank? then
      # the new publications
      @abstracts = Abstract.display_tsearch_no_pagination(@keywords.keywords, @keywords.search_field, params[:limit])
    else
      @abstracts = Abstract.all(:order=>'year desc, publication_date desc, authors ASC', :limit=>params[:limit])
    end
    respond_to do |format|
      format.atom { render :layout => false }

      # we want the RSS feed to redirect permanently to the ATOM feed
      format.rss { redirect_to feed_path(:format => :atom), :status => :moved_permanently }
    end
  end

  def search
    if @keywords.keywords.blank?
      logger.error 'search did not have a defined keyword'
      year_list  # includes a render
    else
      respond_to do |format|
        format.js do
          params[:limit] ||= 30
           @abstracts = Abstract.display_tsearch_no_pagination(@keywords.keywords, @keywords.search_field, params[:limit])
           render layout: false, json: { data: @abstracts.as_json }
        end
        format.html do
          @do_pagination = '1'
          page = params[:page] || 1
          @abstracts = Abstract.display_tsearch(@keywords, @do_pagination, page)
          total_entries = @abstracts.total_entries
          @heading = "There were #{total_entries} matches to search term <i>#{@keywords.keywords.downcase}</i>".html_safe
          @include_mesh = false
          @speed_display = true
          render action: 'year_list'
        end
      end
    end
  end

  def show
    if params[:id].include?('search')
      redirect_to action: 'search'
    elsif params[:id].nil? || params[:id].include?('tag')
      year = handle_year
      redirect_to abstracts_by_year_url(id: year, page: '1')
    else
      @publication = Abstract.include_invalid(params[:id])
    end
  end

  def set_deleted_date
    @publication = Abstract.include_invalid(params[:id])
    if @publication.is_valid
      @publication.is_valid = false
    else
      @publication.is_valid = true
    end
    before_abstract_save(@publication)
    @publication.save!
    render text: ''
  end

  def set_is_cancer
    @publication = Abstract.include_invalid(params[:id])
    if @publication.is_cancer.blank? || !@publication.is_cancer
      @publication.is_cancer = true
    else
      @publication.is_cancer = false
    end
    @publication.save!
    render text: ''
  end

  def set_investigator_abstract_end_date
    @investigatorabstract = InvestigatorAbstract.find(params[:id])
    if @investigatorabstract.is_valid
      @investigatorabstract.is_valid = false
    else
      @investigatorabstract.is_valid = true
    end
    before_abstract_save(@investigatorabstract)
    @investigatorabstract.save!
    render text: ''
  end

  def endnote
    show
  end

  def add_abstracts
  end

  def add_pubmed_ids
    # should be an ajax call
    @pubmed_ids = params[:pubmed_ids]
    @pubmed_ids = @pubmed_ids.gsub(/\, ?/, ' ').split unless @pubmed_ids.blank?
    @abstracts = Abstract.where('pubmed in (:pubmed_ids)', { pubmed_ids: @pubmed_ids }).to_a
  end

  # called as xhr
  def update_pubmed_id
    is_new = false
    if !params[:pubmed_id].blank?
      abstract = Abstract.where("pubmed = :pubmed_id", { :pubmed_id => params[:pubmed_id].split.first }).first
      if abstract.blank?
        is_new = true
        publications = FetchPublicationData(params[:pubmed_id].split)
        InsertPubmedRecords(publications)
        abstract = Abstract.where("pubmed = :pubmed_id", { :pubmed_id => params[:pubmed_id].split.first }).first
      end
      if !abstract.blank?
        investigator_ids = MatchInvestigatorsInCitation(abstract)
        old_investigator_ids = abstract.investigators.map(&:id).sort.uniq
        all_investigator_ids = (investigator_ids | old_investigator_ids).sort.uniq
        new_ids = all_investigator_ids.delete_if { |id| old_investigator_ids.include?(id) }.compact
        # sped this up by only processing the intersection
        if !(new_ids == [])
          new_ids.each do |investigator_id|
            investigator = Investigator.find(investigator_id)
            unless investigator.blank? || investigator.id.blank?
              InsertInvestigatorPublication(abstract.id,
                                            investigator.id,
                                            (abstract.publication_date || abstract.electronic_publication_date || abstract.deposited_date),
                                            IsFirstAuthor(abstract, investigator),
                                            IsLastAuthor(abstract, investigator),
                                            true)
            end
          end
          abstract.reload
        end
      end
    end
    # Is this an XmlHttpRequest request?
    if request.xhr?
      if abstract.blank?
        render text: "Could not find PubMedID #{params[:pubmed_id].to_s}"
      else
        render partial: 'update_pubmed_id', locals: { abstract: abstract, is_new: is_new }
      end
    else
      # No? Or no data? Then render an action.
      redirect_to action: :add_abstracts
    end
  end


  private

  def pre_list(id)
    @redirect = false
    if params[:page].nil?
      params[:page] = '1'
      @redirect = true
    end
    if params[:id].nil? || params[:id].include?('tag')
      params[:id] = id
      @redirect = true
    end
  end

  def journal_heading(journal_name)
    total_entries = total_length(@abstracts)
    @heading = "Publication Listing for <i>#{journal_name}</i>  (#{total_entries} publications)"
  end

  def list_heading(tag)
    total_entries = total_length(@abstracts)
    @heading = "Publication Listing for #{tag} (#{total_entries} publications)"
  end

  def tag_heading(tag_name, abstracts)
    @tags = Abstract.tag_counts(limit: 150, order: 'count desc',
                                conditions: ['abstracts.id in (:abstract_ids)', { abstract_ids: @abstracts.map { |x| x.id } }])
    total_entries = total_length(abstracts)
    @heading = "Publication Listing for the MeSH term <i>#{tag_name}</i>. Found #{total_entries} abstracts"
  end
end
