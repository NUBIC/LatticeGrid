module MeshHelper
  def self.do_mesh_search(search_terms)
    search_terms = search_terms.downcase
    search_terms = search_terms.split(",")
    if only_numerics(search_terms)
    	@tags = Tag.find(:all, :conditions=>["id IN (:ids)", {:ids=>search_terms}])
    else
		  case search_terms.length
  		when 1 : @tags = Tag.find(:all, :conditions=>["lower(name) like :name", {:name=>search_terms[0]+"%"}])
  		when 2 : @tags = Tag.find(:all, :conditions=>["lower(name) like ? or lower(name) like ?", search_terms[0]+"%",search_terms[1]+"%" ])
  		when 3 : @tags = Tag.find(:all, :conditions=>["lower(name) like ? or lower(name) like ? or lower(name) like ?", search_terms[0]+"%", search_terms[1]+"%", search_terms[2]+"%" ])
  		when 4 : @tags = Tag.find(:all, :conditions=>["lower(name) like ? or lower(name) like ? or lower(name) like ? or lower(name) like ?", search_terms[0]+"%", search_terms[1]+"%", search_terms[2]+"%", search_terms[3]+"%" ])
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
