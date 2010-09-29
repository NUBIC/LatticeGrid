module MeshHelper
  def do_mesh_search(search_terms)
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
