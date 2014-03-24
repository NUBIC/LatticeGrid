# -*- coding: utf-8 -*-
##
# Controller to show the new index page
class WelcomeController < ApplicationController
  def index
    @show_side = false
  end

  def unauthorized
  end

  #
  # previous implementation used javascript on the front end to determine the search method to send the request:
  #
  # <% investigator_path_for_form = image_path('../investigators_search/') %>
  # <% investigator_all_path_for_form = image_path('../investigators_search_all/') %>
  # <% default_path_for_form = abstracts_search_url %>
  # <%= form_tag(
  #  investigator_path_for_form, {
  #    :method => :get, :id => 'search_form',
  #    :onsubmit => "the_value = encodeURIComponent($('keywords').value);
  #                if ($('search_field').value.search(/allbyinvestigator/i) != -1)   {
  #                  $('search_form').action = '#{investigator_all_path_for_form}'+the_value
  #                } else if ($('search_field').value.search(/investigator/i) != -1) {
  #                  $('search_form').action = '#{investigator_path_for_form}'+the_value
  #                } else {
  #                  $('search_form').action = '#{default_path_for_form}'} " }
  #  ) do %>
  #
  # so if the keyword selected is
  #  allbyinvestigator -> investigators_search_all
  #  investigator      -> investigators_search
  #  other             -> abstracts_search_url
  #
  # This method consolidates the search form onsubmit logic and redirects to the proper
  # methods based on the selected search_field option
  #
  # @see InvestigatorsHelper#search_options for search_field options
  def search
    case params[:search_field]
    when 'AllByInvestigator'
      redirect_to controller: 'investigators', action: 'search', id: params[:keywords], keywords: params[:keywords]
    when 'Investigator'
      redirect_to controller: 'investigators', action: 'investigators_search', id: params[:keywords], keywords: params[:keywords]
    else
      redirect_to controller: 'abstracts', action: 'search', keywords: params[:keywords], search_field: params[:search_field]
    end
  end

end
