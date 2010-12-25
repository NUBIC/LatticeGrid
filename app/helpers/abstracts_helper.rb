module AbstractsHelper
  def prepare_edit_investigator_listing
    if params[:id] =~ /^\d+$/
      @investigator = Investigator.find(params[:id])
    else
      @investigator = Investigator.find_by_username(params[:id])
    end
    @heading="Publication listing for investigator #{@investigator.name}."
    @include_mesh = false
    @include_graph_link = false
    @show_paginator = false
    @include_investigators=true 
    @include_pubmed_id = true 
  end
end
