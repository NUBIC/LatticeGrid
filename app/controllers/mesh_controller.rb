class MeshController < ApplicationController
  caches_page(:index, :search, :investigators, :investigator) if CachePages()
  
  def index
    @tags = Tag.all
    respond_to do |format|
      format.html 
      format.json { render :layout => false, :json => @tags.to_json() }
      format.xml  { render :layout => false, :xml => @tags.to_xml() }
    end
  end

  def search
    do_search(params[:id])
    respond_to do |format|
      format.html { render }
      format.json { render :layout => false, :json => @tags.to_json() }
      format.xml  { render :layout => false, :xml => @tags.to_xml() }
    end
  end

  def investigators
    do_search(params[:id])
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

private
  def do_search(search_terms)
    search_terms = search_terms.downcase
    search_terms = search_terms.split(" ").collect{ |term| "%"+term+"%" }
    case search_terms.length
    when 1 : @tags = Tag.find(:all, :conditions=>["lower(name) like :name", {:name=>search_terms}])
    when 2 : @tags = Tag.find(:all, :conditions=>["lower(name) like ? and lower(name) like ?", search_terms[0],search_terms[1] ])
    when 3 : @tags = Tag.find(:all, :conditions=>["lower(name) like ? and lower(name) like ? and lower(name) like ?", search_terms[0], search_terms[1], search_terms[2] ])
    when 4 : @tags = Tag.find(:all, :conditions=>["lower(name) like ? and lower(name) like ? and lower(name) like ? and lower(name) like ?", search_terms[0], search_terms[1], search_terms[2], search_terms[3] ])
    end
  end
end
