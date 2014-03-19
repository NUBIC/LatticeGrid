class MeshController < ApplicationController
  caches_page(:index, :search, :investigators, :investigator, :investigator_tags, :tag_count, :investigator_count) if LatticeGridHelper.cache_pages?

  include ApplicationHelper
  include MeshHelper
  include InvestigatorsHelper

  def index
    @tags = Tag.all
    respond_to do |format|
      format.html
      format.json { render :layout => false, :json => @tags.as_json }
      format.xml  { render :layout => false, :xml  => @tags.to_xml }
    end
  end

  def search
    @tags = MeshHelper.do_mesh_search(params[:id])
    respond_to do |format|
      format.html { render }
      format.json { render :layout => false, :json => @tags.as_json }
      format.xml  { render :layout => false, :xml  => @tags.to_xml }
    end
  end

  def investigator_tags
    investigator_id = params[:id]
    handle_member_name(false)
    investigator_id = params[:investigator_id] unless params[:investigator_id].blank?
    @taggings = Tagging.includes(:tag)
                       .where("taggings.taggable_id in (:investigator) and taggings.taggable_type = 'Investigator'",
                          { :investigator=>investigator_id })
                       .order('information_content desc')
                       .all
    respond_to do |format|
      format.html { render }
      format.json { render :layout => false, :json => @taggings.as_json(:include => [:tag]) }
      format.xml  { render :layout => false, :xml  => @taggings.to_xml(:include => [:tag]) }
    end
  end

  def tag_count
    tags = MeshHelper.do_mesh_search(params[:id],true, true)
    tag_total          = Tag.count
    investigator_total = Investigator.count
    abstract_total     = Abstract.count
    investigator_count = 0
    abstract_tag_count = 0
    abstract_count     = 0
    max_investigator_tag_count = 0
    tag_name = params[:id]
    investigators_array = []

    if (tags.length > 0)
      investigators = Investigator.find_tagged_with(tags.collect(&:name), :match_all => true)
      investigator_count = investigators.length
      tagged_abstracts = Tagging.where("taggings.tag_id in (:tag_ids) and taggings.taggable_type = 'Abstract'", { :tag_ids => tags }).to_a
      investigator_abstracts = InvestigatorAbstract.where("investigator_abstracts.abstract_id in (:abstract_ids)", { :abstract_ids => tagged_abstracts.collect(&:taggable_id) }).to_a
      abstract_tag_count = tagged_abstracts.length
      tag_name_array = tags.collect(&:name)
      tag_name = tag_name_array.join(", ")
      if (investigator_count > 0) then
        investigators_array = investigators.collect do |inv|
          tag_count = investigator_abstracts.collect do |ia|
            (ia.investigator_id == inv.id) ? ia.abstract_id : nil
          end.compact.length
          max_investigator_tag_count = tag_count if tag_count.to_i > max_investigator_tag_count.to_i
          { "username" => inv.username, "tag_count" => tag_count, "abstract_count" => inv.total_publications }
        end
      end
    end
    respond_to do |format|
      format.html { render :text => "Tagging count for <i>#{tag_name}</i> (total tags: #{tag_total}; tags found: #{tags.length} )<br/>
                                     Investigators: (#{investigator_count} out of #{investigator_total})<br/>
                                     Abstracts: (#{abstract_tag_count} out of #{abstract_total})" }
      format.json { render :layout => false, :json => {"Tag_name" => tag_name, "Tag_total" => tag_total, "Investigator_total" => investigator_total, "Abstract_total" => abstract_total, "Investigator_count" => investigator_count, "Abstract_count" => abstract_tag_count, "investigators" => investigators_array, "max_investigator_tag_count" => max_investigator_tag_count }.as_json }
      format.xml  { render :layout => false, :xml =>  {"Tag_name" => tag_name, "Tag_total" => tag_total, "Investigator_total" => investigator_total, "Abstract_total" => abstract_total, "Investigator_count" => investigator_count, "Abstract_count" => abstract_tag_count, "investigators" => investigators_array, "max_investigator_tag_count" => max_investigator_tag_count }.to_xml }
    end
  end

  def investigator_count
    tags = MeshHelper.do_mesh_search(params[:id],false,true)
    investigator_count = 0
    if tags.length > 0
      investigator_count = Tagging.where("taggings.tag_id in (:tag_ids) and taggings.taggable_type = 'Investigator'", { :tag_ids => tags }).count
    end
    respond_to do |format|
      format.html { render :text => "Investigator count for #{params[:id]} is #{investigator_count} and tag count is #{tags.length}" }
      format.json { render :layout => false, :json => {"Investigator_count" => investigator_count}.as_json }
      format.xml  { render :layout => false, :xml  => {"Investigator_count" => investigator_count}.to_xml }
    end
  end

  def investigators
    tags = MeshHelper.do_mesh_search(params[:id],false,true)

    tag_array = tags.collect do |tag|
      tagged_abstracts = Tagging.where("taggings.tag_id = :tag_id and taggings.taggable_type = 'Abstract'", { :tag_id => tag.id }).to_a
      investigator_abstracts = InvestigatorAbstract.where('investigator_abstracts.abstract_id in (:abstract_ids)', { :abstract_ids => tagged_abstracts.collect(&:taggable_id) }).to_a
      investigators = Investigator.find_tagged_with(tag.name)
      investigators_array = investigators.collect do |inv|
        abstract_count = inv.total_publications
        tag_count = investigator_abstracts.collect{ |ia| (ia.investigator_id == inv.id) ? ia.abstract_id : nil }.compact.length
        { "username" => inv.username, "tag_count" => tag_count, "abstract_count" => abstract_count }
      end
      { "name" => tag.name, "investigators" => investigators_array }
    end

    respond_to do |format|
      format.html { render :text => "Tags found: (#{tags.length}); Tags: #{tag_array}"}
      format.json { render :layout => false, :json => { "tags" => tag_array}.as_json }
      format.xml  { render :layout => false, :xml =>  { "tags" => tag_array}.to_xml }
    end
  end

  def investigator
    params[:username] = params[:username] || params[:id]
    tags = Investigator.find_by_username(params[:username]).abstracts.tag_counts(:order => "count desc")

    respond_to do |format|
      format.html { redirect_to show_all_tags_investigator_url(params[:username]) }
      format.xml  { render :layout => false, :xml  => tags.to_xml }
      format.json { render :layout => false, :json => tags.as_json }
    end
  end

end
