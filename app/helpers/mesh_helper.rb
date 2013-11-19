module MeshHelper
  def self.do_mesh_search(search_terms, exact_match = false, ignore_split = false)
    search_terms = search_terms.downcase
    search_terms = ignore_split ? [search_terms] : search_terms.split(",")

    match_suffix = exact_match ? "" : "%"

    if only_numerics(search_terms)
    	@tags = Tag.where('id IN (:ids)', { :ids => search_terms })
    else
		  case search_terms.length
  		when 1
        @tags = Tag.where('lower(name) like ?',
                          match_suffix+search_terms[0]+match_suffix).to_a
  		when 2
        @tags = Tag.where('lower(name) like ? or lower(name) like ?',
                          match_suffix+search_terms[0]+match_suffix,
                          match_suffix+search_terms[1]+match_suffix).to_a
  		when 3
        @tags = Tag.where('lower(name) like ? or lower(name) like ? or lower(name) like ?',
                          match_suffix+search_terms[0]+match_suffix,
                          match_suffix+search_terms[1]+match_suffix,
                          match_suffix+search_terms[2]+match_suffix).to_a
  		when 4
        @tags = Tag.where('lower(name) like ? or lower(name) like ? or lower(name) like ? or lower(name) like ?',
                          match_suffix+search_terms[0]+match_suffix,
                          match_suffix+search_terms[1]+match_suffix,
                          match_suffix+search_terms[2]+match_suffix,
                          match_suffix+search_terms[3]+match_suffix).to_a
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
