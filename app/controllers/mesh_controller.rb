class MeshController < ApplicationController
  caches_page(:index, :search, :investigators, :investigator) if CachePages()

  include ApplicationHelper
  include MeshHelper
  
  def index
    @tags = Tag.all
    respond_to do |format|
      format.html 
      format.json { render :layout => false, :json => @tags.to_json() }
      format.xml  { render :layout => false, :xml => @tags.to_xml() }
    end
  end

  def search
    do_mesh_search(params[:id])
    respond_to do |format|
      format.html { render }
      format.json { render :layout => false, :json => @tags.to_json() }
      format.xml  { render :layout => false, :xml => @tags.to_xml() }
    end
  end

  def investigators
    do_mesh_search(params[:id])
    @investigators = Investigator.find_tagged_with(@tags.collect(&:name))
    # , :order => 'lower(last_name),lower(first_name)'
    respond_to do |format|
      format.html { render }
      format.json { render :layout => false, :json => @investigators.to_json() }
      format.xml  { render :layout => false, :xml => @investigators.to_xml() }
    end
  end
  
  def investigator
    params[:username]=params[:username]||params[:id]
    tags = Investigator.find_by_username(params[:username]).abstracts.tag_counts( :order => "count desc")
    
    respond_to do |format|
      format.html { redirect_to show_all_tags_investigator_url(params[:username]) }
      format.xml  { render :layout => false, :xml  => tags.to_xml() }
      format.json { render :layout => false, :json => tags.to_json() }
    end
  end

end
