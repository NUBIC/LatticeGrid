module AbstractsHelper
  include ProfilesHelper

  def prepare_edit_investigator_listing
    if params[:id] =~ /^\d+$/
      @investigator = Investigator.find(params[:id])
    else
      @investigator = Investigator.find_by_username(params[:id])
    end
    if @investigator.blank?
      @heading = "Error: Could not find investigator #{params[:id]}"
    else
      @heading="Publication listing for investigator #{@investigator.name}."
    end
    @include_mesh = false
    @include_graph_link = false
    @show_paginator = false
    @include_investigators=true
    @include_pubmed_id = true
  end

  def before_abstract_save(model)
    model.last_reviewed_ip = request.remote_ip if defined?(request)
    model.last_reviewed_at = Time.now
    if LatticeGridHelper.require_authentication? and current_user
      model.last_reviewed_id = current_user_model.id if defined?(current_user_model)
      model.reviewed_id ||= current_user_model.id if defined?(current_user_model) and model.reviewed_at.blank?
    end
    model.reviewed_ip ||= request.remote_ip if defined?(request)
    model.reviewed_at ||= Time.now
  end
end
