module MeshHelper
  def self.do_mesh_search(search_terms, exact_match=false, ignore_split=false)
    search_terms = search_terms.downcase
    if ignore_split
      search_terms = [search_terms]
    else
      search_terms = search_terms.split(",")
    end
    match_suffix = "%"
    match_suffix = "" if exact_match
    if only_numerics(search_terms)
    	@tags = Tag.find(:all, :conditions=>["id IN (:ids)", {:ids=>search_terms}])
    else
		  case search_terms.length
  		when 1 : @tags = Tag.find(:all, :conditions=>["lower(name) like :name", {:name=>match_suffix+search_terms[0]+match_suffix}])
  		when 2 : @tags = Tag.find(:all, :conditions=>["lower(name) like ? or lower(name) like ?", match_suffix+search_terms[0]+match_suffix,match_suffix+search_terms[1]+match_suffix ])
  		when 3 : @tags = Tag.find(:all, :conditions=>["lower(name) like ? or lower(name) like ? or lower(name) like ?", match_suffix+search_terms[0]+match_suffix, match_suffix+search_terms[1]+match_suffix, match_suffix+search_terms[2]+match_suffix ])
  		when 4 : @tags = Tag.find(:all, :conditions=>["lower(name) like ? or lower(name) like ? or lower(name) like ? or lower(name) like ?", match_suffix+search_terms[0]+match_suffix, match_suffix+search_terms[1]+match_suffix, match_suffix+search_terms[2]+match_suffix, match_suffix+search_terms[3]+match_suffix ])
  		end
	  end
	  @tags
  end
  
  def self.only_numerics(term_array)
  	term_array.each do |term|
  		return false unless term =~ /^[0-9]+$/
  	end
  	return true
  end
  
end
