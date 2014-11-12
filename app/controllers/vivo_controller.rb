# -*- coding: utf-8 -*-

##
# Controller for data visualizations with data retrieved from VIVO
class VivoController < ApplicationController

  def investigator_chord
    @title = '[VIVO] Chord Diagram showing publications between various investigators'
    unless params[:id].blank?
      @investigator = Investigator.find_by_username(params[:id])
      @json_callback = "../vivo/#{params[:id]}/d3_investigator_chord_data.js"
      if @investigator.blank?
        flash[:notice] = 'Unable to find investigator'
        params[:id] = nil
      else
        @title = 'Chord Diagram showing investigator collaborations through publications for ' + @investigator.name
      end
    end
    respond_to do |format|
      format.html { render layout: 'vivo' }
      format.json { render layout: false, text: '' }
    end
  end

  def d3_investigator_chord_data
    if params[:id]
      investigator = Investigator.find_all_by_username(params[:id]).first
      file = "#{Rails.root}/tmp/vivo/chord_data/#{investigator.uuid}.json"
    end
    respond_to do |format|
      format.json { send_file file, :type => 'text/json', :disposition => 'inline' }
      format.js   { send_file file, :type => 'text/json', :disposition => 'inline' }
    end
  end

end