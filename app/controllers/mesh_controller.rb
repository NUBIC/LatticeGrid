class MeshController < ApplicationController
  caches_page(:index, :search, :investigators, :investigator) if CachePages()

  include ApplicationHelper
  include MeshHelper
  include InvestigatorsHelper
  
  def index
    @tags = Tag.all
    respond_to do |format|
      format.html 
      format.json { render :layout => false, :json => @tags.to_json() }
      format.xml  { render :layout => false, :xml => @tags.to_xml() }
    end
  end

  def search
    @tags = MeshHelper.do_mesh_search(params[:id])
    respond_to do |format|
      format.html { render }
      format.json { render :layout => false, :json => @tags.to_json() }
      format.xml  { render :layout => false, :xml => @tags.to_xml() }
    end
  end

  def investigator_tags
    investigator_id = params[:id]
    handle_member_name
    investigator_id = params[:investigator_id] unless params[:investigator_id].blank?
    @taggings = Tagging.find(:all,
       :include => [:tag],
       :conditions => [" taggings.taggable_id in (:investigator) and taggings.taggable_type = 'Investigator'", {:investigator=>investigator_id} ],
       :order => 'information_content desc')
    respond_to do |format|
      format.html { render }
      format.json { render :layout => false, :json => @taggings.to_json(:include => [:tag]) }
      format.xml  { render :layout => false, :xml => @taggings.to_xml(:include => [:tag]) }
    end
  end
  
  def tag_count
    tags = MeshHelper.do_mesh_search(params[:id])
    @tag_total          = Tag.count
    @investigator_total = Investigator.count
    @abstract_total     = Abstract.count
    @investigator_count = 0
    @abstract_count     = 0
    @tag_name = params[:id]
    if tags.length > 0
      @investigator_count = Tagging.count(
       :conditions => [" taggings.tag_id in (:tag_ids) and taggings.taggable_type = 'Investigator'", {:tag_ids=>tags} ]) 
      @abstract_count = Tagging.count(
       :conditions => [" taggings.tag_id in (:tag_ids) and taggings.taggable_type = 'Abstract'", {:tag_ids=>tags} ]) 
      @tag_name = tags.collect(&:name).join(", ")
    end
    respond_to do |format|
      format.html { render :text => "Tagging count for <i>#{@tag_name}</i> (total tags: #{@tag_total})<br/>
      Investigators: (#{@investigator_count} out of #{@investigator_total})<br/>
      Abstracts: (#{@abstract_count} out of #{@abstract_total})"}
      format.json { render :layout => false, :json => {"Tag_name" => @tag_name, "Tag_total" => @tag_total, "Investigator_total" => @investigator_total, "Abstract_total" => @abstract_total, "Investigator_count" => @investigator_count, "Abstract_count" => @abstract_count }.as_json() }
      format.xml  { render :layout => false, :xml => {"Tag_name" => @tag_name, "Tag_total" => @tag_total, "Investigator_total" => @investigator_total, "Abstract_total" => @abstract_total, "Investigator_count" => @investigator_count, "Abstract_count" => @abstract_count }.to_xml() }
    end
  end

  def investigator_count
    tags = MeshHelper.do_mesh_search(params[:id])
    @investigator_count = 0
    @investigator_count = Tagging.count(
       :conditions => [" taggings.tag_id in (:tag_ids) and taggings.taggable_type = 'Investigator'", {:tag_ids=>tags} ]) if tags.length > 0
    respond_to do |format|
      format.html { render :text => "Investigator count for #{params[:id]} is #{@investigator_count}" }
      format.json { render :layout => false, :json => {"Investigator_count" => @investigator_count}.as_json() }
      format.xml  { render :layout => false, :xml => {"Investigator_count" => @investigator_count}.to_xml() }
    end
  end

  def investigators
    @tags = MeshHelper.do_mesh_search(params[:id])    
    investigators = Investigator.find_tagged_with(@tags.collect(&:name), :match_all => :true)
    @investigators = Investigator.find(:all,
      :joins => [:tags,:taggings],
      :conditions => ["investigators.id in (:investigators) and taggings_investigators.tag_id in (:tags)", {:investigators=>investigators, :tags => @tags}]).uniq
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
