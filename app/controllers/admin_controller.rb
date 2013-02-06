class AdminController < ApplicationController
  before_filter :check_login
#  after_filter  :log_request, :except => [:login, :welcome, :splash, :show_pubs, :edit, :edit_pubs, :ccsg]
  after_filter :require_admin
  
  include Aker::Rails::SecuredController if LatticeGridHelper.require_authentication?
  include ProfilesHelper
  include InvestigatorsHelper
  include ApplicationHelper
  include AbstractsHelper
  include OrgsHelper
  
  require 'format_helper'
  require 'pubmed_utilities'  
  require 'cache_utilities'
  
  def index
    @valid_investigators = Investigator.count
    @investigators = Investigator.include_deleted
  end
  
  def show
  end
  
  def edit
    handle_member_name(false) # converts params[:id] to params[:investigator_id] and sets @investigator
    @programs = Program.all
  end

  def new
    @investigator = Investigator.new
    @investigator.investigator_appointments.build
    @programs = Program.all
  end
  
  def delete
  end
  
  # PUT /admin/1
  # PUT /admin/1.xml
  def update
    handle_member_name(false) # converts params[:id] to params[:investigator_id] and sets @investigator
    before_update(@investigator)
    handle_investigator_delete(@investigator, params[:delete])
    respond_to do |format|
      params[:investigator].delete(:id)  #id causes an error  - can't mass assign id
      params[:investigator]["era_comons_name"] = nil if params[:investigator]["era_comons_name"].blank?
#      @investigator.investigator_appointments_form = params[:investigator]["investigator_appointments_form"] unless params[:investigator]["investigator_appointments_form"].blank?
      if @investigator.update_attributes(params[:investigator])
        #nparams = handle_investigator_investigator_apppointments_update(params, get_member_type(@investigator))
        clear_directory("investigators/#{@investigator.username}")
        clear_file("profiles/#{@investigator.username}.html")
        flash[:errors] = nil
        flash[:notice] = "Investigator <i>'#{@investigator.name}'</i> was successfully updated"
        unless @investigator.errors.blank?
          flash[:errors] = "Investigator was saved but: " + @investigator.errors.full_messages.join("; ")
        end
        format.html { redirect_to( investigator_url(@investigator.username)) }
        format.xml  { head :ok }
      else
        flash[:errors] = "Investigator was saved but: " + @investigator.errors.full_messages.join("; ")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @investigator.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create
    @investigator = Investigator.new(params[:investigator])
    before_create(@investigator)
    respond_to do |format|
      if @investigator.save
        @investigator.update_attributes(params[:investigator])
        flash[:errors] = nil
        flash[:notice] = "Investigator <i>'#{@investigator.name}'</i> was successfully created"
        unless @investigator.errors.blank?
          flash[:errors] = "Investigator was saved but: " + @investigator.errors.full_messages.join("; ")
        end
        format.html { redirect_to( investigator_url(@investigator.username)) }
        format.xml  { head :ok }
      else
        flash[:errors] = "Investigator was saved but: " + @investigator.errors.full_messages.join("; ")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @investigator.errors, :status => :unprocessable_entity }
      end
    end
  end


end
