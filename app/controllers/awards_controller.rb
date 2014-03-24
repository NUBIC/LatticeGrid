# -*- coding: utf-8 -*-

# Controller having to do with award/grant information
class AwardsController < ApplicationController
  include InvestigatorsHelper
  include AwardsHelper
  include ApplicationHelper
  include OrgsHelper

  require 'format_helper'
  require 'cytoscape_generator'

  before_filter :check_allowed, except: [:disallowed]
  caches_action(:listing, :investigator, :show, :org) if LatticeGridHelper.cache_pages?

  def show
    if params[:id].nil?
      redirect_to current_abstracts_url
    else
      if params[:id] =~ /^\d+$/
        @award = Proposal.find(params[:id])
      else
        @award = Proposal.find_by_institution_award_number(params[:id])
      end
      respond_to do |format|
        format.html { render }
      end
    end
  end

  def listing
    @javascripts_add = ['jquery-1.8.3', 'jquery.tablesorter.min', 'jquery.fixheadertable.min']
    @investigators = Investigator.proposal_totals
    @css =  '#main {width:1900px;}'
    respond_to do |format|
      format.html { render layout: 'printable' }
      format.xml  { render xml: @investigators }
      format.xls do
        @pdf = 1
        award_data = render_to_string(template: 'awards/listing.html', layout: 'excel')
        send_data(award_data,
                  filename: "award_listing_#{Date.today.to_s}.xls",
                  type: 'application/vnd.ms-excel',
                  disposition: 'attachment')
      end
      format.doc do
        @pdf = 1
        award_data = render_to_string(template: 'awards/listing.html', layout: 'excel')
        send_data(award_data,
                  filename: "award_listing_#{Date.today.to_s}.doc",
                  type: 'application/msword',
                  disposition: 'attachment')
      end
      format.pdf do
        @pdf = true
        render(pdf: 'Investigator Awards Listing',
               stylesheets: ['pdf'],
               template: 'awards/listing.html',
               layout: 'pdf')
      end
    end
  end

  def investigator
    @javascripts_add = ['jquery-ui.min']
    @stylesheets = ['publications', "latticegrid/#{lattice_grid_instance}", 'jquery-ui', 'ddsmoothmenu', 'ddsmoothmenu-v']
    if params[:id].nil?
      redirect_to current_abstracts_url
    else
      handle_member_name(false) # sets @investigator
      @pi_awards = @investigator.investigator_proposals.by_role
      respond_to do |format|
        format.html { render }
        format.xml  { render xml: @investigator.proposals }
        format.xls do
          @pdf = 1
          award_data = render_to_string(template: 'awards/investigator.html', layout: 'excel')
          send_data(award_data,
                    filename: "award_listing_for_#{@investigator.first_name}_#{@investigator.last_name}.xls",
                    type: 'application/vnd.ms-excel',
                    disposition: 'attachment')
        end
        format.doc do
          @pdf = 1
          award_data = render_to_string(template: 'awards/investigator.html', layout: 'excel')
          send_data(award_data,
                    filename: "award_listing_for_#{@investigator.first_name}_#{@investigator.last_name}.doc",
                    type: 'application/msword',
                    disposition: 'attachment')
        end
        format.pdf do
          @pdf = 1
          render(pdf: "Award listing for #{@investigator.name}",
                 stylesheets: ['pdf'],
                 template: 'awards/investigator.html',
                 layout: 'pdf')
        end
      end
    end
  end

  def recent
    if params[:start_date].nil? || params[:end_date].nil?
      redirect_to current_abstracts_url
    else
      @javascripts_add = ['jquery-1.8.3', 'jquery.tablesorter.min', 'jquery.fixheadertable.min', 'jquery-ui.min']
      @stylesheets = ['publications', "latticegrid/#{lattice_grid_instance}", 'jquery-ui', 'ddsmoothmenu', 'ddsmoothmenu-v']
      @awards = Proposal.recents_by_type(params[:funding_types], params[:start_date], params[:end_date])
      previous = nil
      @css = '#main {width:1900px;}'
      if params[:funding_types].blank?
        funding_source = ''
      elsif params[:funding_types].class.to_s =~ /array/i
        funding_source = " for source types #{params[:funding_types].join(', ')}"
      else
        funding_source = " for source type #{params[:funding_types]}"
      end
      @title = "Funding awards started between #{params[:start_date]} and #{params[:end_date]} #{funding_source}"
      @awards_total = @awards.map do |a|
        val = (previous.blank? || previous != a.id) ? a.total_amount : 0
        previous = a.id
        val
      end.inject(0){ |sum, element| sum + element }
      respond_to do |format|
        format.html { render action: :org, layout: 'printable' }
        format.xml  { render xml: @awards }
        format.xls do
          @pdf = 1
          award_data = render_to_string(template: 'awards/org.html', layout: 'excel')
          send_data(award_data,
                    filename: "award_listing_between_#{params[:start_date]}_and_#{params[:end_date]}_#{funding_source}.xls",
                    type: 'application/vnd.ms-excel',
                    disposition: 'attachment')
        end
        format.doc do
          @pdf = 1
          award_data = render_to_string(template: 'awards/org.html', layout: 'excel')
          send_data(award_data,
                    filename: "award_listing_between_#{params[:start_date]}_and_#{params[:end_date]}_#{funding_source}.doc",
                    type: 'application/msword',
                    disposition: 'attachment')
        end
        format.pdf do
          @pdf = 1
          render(pdf: "Award listing between #{params[:start_date]} and #{params[:end_date]} #{funding_source}",
                 stylesheets: ['pdf'],
                 template: 'awards/org.html',
                 layout: 'pdf')
        end
      end
    end
  end

  def ad_hoc_by_pi
    if params[:start_date].nil? || params[:end_date].nil?
      redirect_to current_abstracts_url
    else
      @javascripts_add = ['jquery-1.8.3', 'jquery.tablesorter.min', 'jquery.fixheadertable.min', 'jquery-ui.min']
      @stylesheets = ['publications', "latticegrid/#{lattice_grid_instance}", 'jquery-ui', 'ddsmoothmenu', 'ddsmoothmenu-v']

      @faculty = Investigator.find_investigators_in_list(params[:investigator_ids]).sort do |x, y|
        x.last_name + ' ' + x.first_name <=> y.last_name + ' ' + y.first_name
      end
      @investigators_in_unit = @faculty.map(&:id).sort.uniq

      @awards = Proposal.recents_by_pi(@investigators_in_unit, params[:start_date], params[:end_date])
      previous = nil
      @css =  '#main {width:1900px;}'
      @title = "Funding awards started between #{params[:start_date]} and #{params[:end_date]}"

      @awards_total = @awards.map do |a|
        val = (previous.blank? || previous != a.id) ? a.total_amount : 0
        previous = a.id
        val
      end.inject(0) { |sum, element| sum + element }
      respond_to do |format|
        format.html { render action: :org, layout: 'printable' }
        format.xml  { render xml: @awards }
        format.xls do
          @pdf = 1
          award_data = render_to_string(template: 'awards/org.html', layout: 'excel')
          send_data(award_data,
                    filename: "award_listing_for_#{params[:funding_type]}.xls",
                    type: 'application/vnd.ms-excel',
                    disposition: 'attachment')
        end
        format.doc do
          @pdf = 1
          award_data = render_to_string(template: 'awards/org.html', layout: 'excel')
          send_data(award_data,
                    filename: "award_listing_for_#{params[:funding_type]}.doc",
                    type: 'application/msword',
                    disposition: 'attachment')
        end
        format.pdf do
          @pdf = 1
          render(pdf: "Award listing for #{params[:funding_type]}",
                 stylesheets: ['pdf'],
                 template: 'awards/org.html',
                 layout: 'pdf')
        end
      end
    end
  end

  def org
    @javascripts_add = ['jquery-ui.min']
    @stylesheets = ['publications', "latticegrid/#{lattice_grid_instance}", 'jquery-ui', 'ddsmoothmenu', 'ddsmoothmenu-v']
    if params[:id].nil?
      redirect_to current_abstracts_url
    else
      @unit = find_unit_by_id_or_name(params[:id])
      @investigators = @unit.all_primary_or_member_faculty
      @investigator_ids = @investigators.map(&:id)
      @awards = Proposal.belonging_to_pi_ids(@investigator_ids)
      previous = nil
      @awards_total = @awards.map do |a|
        val = (previous.blank? || previous != a.id) ? a.total_amount : 0
        previous = a.id
        val
      end.inject(0) { |sum, element| sum + element }
      respond_to do |format|
        format.html { render }
        format.xml  { render xml: @investigator.proposals }
        format.xls do
          @pdf = 1
          award_data = render_to_string(template: 'awards/org.html', layout: 'excel')
          send_data(award_data,
                    filename: "award_listing_for_#{@unit.name}.xls",
                    type: 'application/vnd.ms-excel',
                    disposition: 'attachment')
        end
        format.doc do
          @pdf = 1
          award_data = render_to_string(template: 'awards/org.html', layout: 'excel')
          send_data(award_data,
                    filename: "award_listing_for_#{@unit.name}.doc",
                    type: 'application/msword',
                    disposition: 'attachment')
        end
        format.pdf do
          @pdf = 1
          render(pdf: "Award listing for #{@unit.name}",
                 stylesheets: ['pdf'],
                 template: 'awards/org.html',
                 layout: 'pdf')
        end
      end
    end
  end

  def check_allowed
    redirect_to disallowed_awards_url unless allowed_ip(get_client_ip)
  end
  private :check_allowed
end
