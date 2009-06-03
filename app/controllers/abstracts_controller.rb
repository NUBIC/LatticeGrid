class AbstractsController < ApplicationController
  caches_page :year_list, :full_year_list, :tag_cloud, :tag, :endnote, :full_tag
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :search ],
         :redirect_to => { :action => :year_list }

   def index
     redirect_to year_list_abstract_path(:id => @year, :page => '1')
   end

  def year_list
    redirect=false
    if params[:page].nil? then
      params[:page] = "1"
      redirect=true
    end
    if params[:id].nil? || params[:id].include?("tag") then
      params[:id]= @year
      redirect=true
    end
    if redirect then
      redirect_to params
    else
      handle_year(params[:id]) if params[:id] != @year
      @abstracts = Abstract.display_data( @year, params[:page] )
      list_heading
      @do_pagination = "1"
    end
  end

  def full_year_list
    if params[:id].nil? then
      redirect_to year_list_abstract_path(:id => @year, :page => '1')
    elsif !params[:page].nil? then
      params.delete(:page)
      redirect_to params
    else
      handle_year(params[:id]) if params[:id] != @year
      @abstracts = Abstract.display_all_data( @year )
      list_heading
      @do_pagination = "0"
      render :action => 'list'
    end
  end

  def tag_cloud
     @tags = Abstract.tag_counts(:limit => 150, :order => "count desc")
  end
  
  def tag
    redirect=false
    if params[:page].nil? then
      params[:page] = "1"
      redirect=true
    end
    if params[:id].nil? then
      redirect_to year_list_abstract_path(:id => @year, :page => '1')
    elsif redirect then
      redirect_to params
    else
      @do_pagination = "1"
      @abstracts = Abstract._paginate_tagged_with(params[:id],
                                        :order => 'year DESC, authors ASC',
                                        :page => params[:page],
                                        :per_page => 20)
     tag_heading
    end
  end

  def full_tag
    @do_pagination = "0"
    @abstracts = Abstract.find_tagged_with(params[:id], :order => 'year DESC, authors ASC')
    tag_heading
    render :action => 'tag'
  end

  def ccsg
    @date_range = DateRange.new(1.year.ago,Time.now)
  end

  def search 
     if !@keywords.keywords.blank? then
 #      @tags = Abstract.tag_counts(:limit => 150, :order => "count desc")
      @do_pagination="1"
       @abstracts = Abstract.display_search(@keywords, @do_pagination, params[:page])
       if @do_pagination != '0'
         total_entries=@abstracts.total_entries
       else
         total_entries=@abstracts.length
       end
       @heading = "There were #{total_entries} matches to search term <i>"+ @keywords.keywords.downcase + "</i>"
       @include_mesh=false
       render :action => 'year_list'
     else 
       redirect_to year_list_abstract_path(:id => @year, :page => '1')
     end 
  end 
  
  def show
    if params[:id].include?("search") then
      redirect_to :action => 'search'
    elsif params[:id].nil? || params[:id].include?("tag") then
      redirect_to year_list_abstract_path(:id => @year, :page => '1')
    else
      @publication = Abstract.find(params[:id])
    end
  end

  def endnote
    show
  end
  
  private
  
  def list_heading
    @tags = Abstract.tag_counts(:limit => 150, :order => "count desc", 
                  :conditions => ["abstracts.year in (:year)", {:year=>@year }])
    total_entries = total_length(@abstracts) 
    @heading = "Publication Listing for #{@year}  (#{total_entries} publications)"
  end
  
  def tag_heading
    @tags = Abstract.tag_counts(:limit => 150, :order => "count desc", 
                  :conditions => ["abstracts.id in (:abstract_ids)", {:abstract_ids=>@abstracts.collect{|x| x.id}}])
    total_entries = total_length(@abstracts) 
    @heading = "Publication Listing for the MeSH term <i>#{params[:id]}</i>. Found #{total_entries} abstracts"
  end
end
